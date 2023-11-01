import getpass
import json
from subprocess import Popen, PIPE, STDOUT
import os
import pathlib
import xbmc
import xbmcgui
import re
from xbmcvfs import translatePath


def launch(addon, hostname=None, game_name=None):
    # Check if moonlight is installed and offer to install
    if is_moonlight_installed() is False:
        update(addon)

    # If moonlight is still not installed abort
    if is_moonlight_installed() is False:
        dialog = xbmcgui.Dialog()
        dialog.ok(addon.getLocalizedString(30200), addon.getLocalizedString(30201))
        return

    # Initialise argument vars
    systemd_args = []
    moonlight_command = f'bash {get_resource_path("bin/launch_moonlight-qt.sh")}'
    moonlight_args = []

    # Check if systemd-run can be used in user-mode
    if os.environ.get('DBUS_SESSION_BUS_ADDRESS') is not None or os.environ.get('XDG_RUNTIME_DIR') is not None:
        systemd_args.append('--user')
    elif os.geteuid() != 0:
        # If systemd user-mode can't be used and the current kodi-user is not root, try sudo for switching (OSMC)
        moonlight_command = f'sudo -u {getpass.getuser()} {moonlight_command}'

    # Check for a forced EGL display mode
    force_mode = addon.getSetting('display_egl_resolution')
    if force_mode != "default":
        systemd_args.append(f'--setenv=FORCE_EGL_MODE="{force_mode}"')

    # Append addon path
    systemd_args.append(f'--setenv=ADDON_PROFILE_PATH="{get_addon_data_path()}"')

    # Resolve audio output device
    try:
        service = 'Default'
        device_name = 'Default'
        kodi_audio_device = get_kodi_audio_device()

        if len(kodi_audio_device) == 1:
            service = kodi_audio_device[0]
        if len(kodi_audio_device) == 2:
            service, device_name = kodi_audio_device

        if service == 'ALSA':
            # Disable PulseAudio output by using a Moonlight environment variable
            systemd_args.append('--setenv=PULSE_SERVER="none"')
            systemd_args.append('--setenv=SDL_AUDIODRIVER="alsa"')
            speaker_setup_write_alsa_config(addon)
        elif service == 'PULSE':
            # Tell pulse to use a specific device configured in Kodi
            systemd_args.append(f'--setenv=PULSE_SINK="{device_name}"')
        elif service != 'Default':
            # Raise a warning when ALSA and PULSE are not detected
            raise RuntimeError(f'Audio service {service} not supported')
    except Exception as err:
        xbmc.log(
            f'Failed to resolve audio output device, audio within Moonlight might not work: {err}', xbmc.LOGWARNING
        )

    # Create command to launch moonlight
    launch_command = 'systemd-run {} {}'.format(' '.join(systemd_args), moonlight_command)

    # Check if at least a host is set
    if hostname and game_name:
        moonlight_args.extend(['stream', f'"{hostname}"', f'"{game_name}"'])

    # Prepare the command
    command = f'{launch_command} ' + ' '.join(moonlight_args)

    # Log the command so debugging problems is easier
    xbmc.log(f'Launching moonlight-qt: {command}', xbmc.LOGINFO)

    # Show a dialog
    if not game_name:
        game_name = addon.getLocalizedString(30001)

    launch_label = addon.getLocalizedString(30202) % {'game': game_name}

    p_dialog = xbmcgui.DialogProgress()
    p_dialog.create(addon.getLocalizedString(30200), launch_label)
    p_dialog.update(50)

    # Wait for the dialog to pop up
    xbmc.sleep(200)

    # Run the command
    exitcode = os.system(command)

    # If the command was successful wait for moonlight to shut down kodi
    if exitcode == 0:
        xbmc.sleep(1000)
    else:
        # If moonlight did not start notify the user
        xbmc.log('Launching moonlight-qt failed: ' + command, xbmc.LOGERROR)
        p_dialog.close()
        dialog = xbmcgui.Dialog()
        dialog.ok(addon.getLocalizedString(30200), addon.getLocalizedString(30203))


def update(addon):
    if is_moonlight_installed():
        install_label = addon.getLocalizedString(30102)
    else:
        install_label = addon.getLocalizedString(30101)

    c_dialog = xbmcgui.Dialog()
    confirm_update = c_dialog.yesno(addon.getLocalizedString(30100), install_label)

    if confirm_update is False:
        return

    p_dialog = xbmcgui.DialogProgress()
    p_dialog.create(addon.getLocalizedString(30103), addon.getLocalizedString(30104))

    xbmc.log('Updating moonlight-qt...', xbmc.LOGDEBUG)

    # This is an estimate of how many lines of output there should be to guess the progress
    line_max = 2210
    line_nr = 1
    line = ''

    cmd = 'ADDON_PROFILE_PATH="{}" bash {} | tee {}'.format(
        get_addon_data_path(),
        get_resource_path('build/build.sh'),
        get_addon_data_path('/build.log')
    )
    xbmc.log(f'Launching moonlight-qt update: {cmd}', xbmc.LOGINFO)
    p = Popen(cmd, stdout=PIPE, stderr=STDOUT, shell=True)
    for line in p.stdout:
        percent = int(round(line_nr / line_max * 100))
        p_dialog.update(percent)
        line_nr += 1
    p.wait()

    # Log update
    xbmc.log('Updating moonlight-qt finished with {} lines of output and exit-code {}: {}'.format(
        line_nr.__str__(), p.returncode.__str__(), line.decode()
    ), xbmc.LOGDEBUG)

    # Make sure it ends at 100%
    p_dialog.update(100)

    # Close the progress bar
    p_dialog.close()

    if p.returncode == 0 and is_moonlight_installed():
        finish_label = addon.getLocalizedString(30106)
    else:
        finish_label = addon.getLocalizedString(30105) % {'error_msg': line.decode()}

    dialog = xbmcgui.Dialog()
    dialog.ok(addon.getLocalizedString(30103), finish_label)


def speaker_test(addon, speakers):
    dialog = xbmcgui.Dialog()
    service, device_name = get_kodi_audio_device()

    if service == 'ALSA':
        p_dialog = xbmcgui.DialogProgress()
        p_dialog.create('Speaker test', 'Initializing...')

        # Make sure Kodi does not keep the device occupied
        streamsilence_user_setting = get_kodi_setting('audiooutput.streamsilence')
        set_kodi_setting('audiooutput.streamsilence', 0)

        # Write new config file
        speaker_setup_write_alsa_config(addon)

        # Get Path for moonlight home
        home_path = get_moonlight_home_path()

        # Get device name foor surround sound
        non_lfe_speakers = speakers - 1
        device_name = 'surround{}1'.format(non_lfe_speakers)

        for speaker in range(speakers):
            # Display dialog text
            speaker_channel = addon.getSettingInt('alsa_surround_{}1_{}'.format(non_lfe_speakers, speaker))

            # Prepare dialog info
            dialog_percent = int(round((speaker + 1) / speakers * 100))
            dialog_text = 'Testing {} speaker on channel {}...' \
                .format(addon.getLocalizedString(30030 + speaker), speaker_channel)

            # Prepare command
            cmd = 'HOME="{}" speaker-test --nloops 1 --device {} --channels {} --speaker {}' \
                .format(home_path, device_name, speakers, speaker + 1)

            # For same reason the device is not always available, try until the command succeeds
            exit_code = 1
            while exit_code != 0:
                # Stop if user aborts test dialog
                if p_dialog.iscanceled():
                    break

                # Update dialog info
                p_dialog.update(dialog_percent, dialog_text)

                # Play test sound
                xbmc.log(cmd, xbmc.LOGINFO)
                exit_code = os.system(cmd)

                # If the command failed, tell the user and wait for a short time before retrying
                if exit_code != 0:
                    xbmc.log('Failed executing "{}"'.format(cmd), xbmc.LOGWARNING)

                    p_dialog.update(
                        dialog_percent,
                        'Waiting for {}.1 Surround audio device to become available...'.format(non_lfe_speakers)
                    )

                    xbmc.sleep(500)

            # Stop if user aborts test dialog
            if p_dialog.iscanceled():
                break

        # Restore user setting
        set_kodi_setting('audiooutput.streamsilence', streamsilence_user_setting)

        # Close the progress bar
        p_dialog.close()

    else:
        dialog.ok('Speaker test', 'Audio service is {}, not ALSA.\n\nTest aborted.'.format(service))

    addon.openSettings()


def speaker_setup_write_alsa_config(addon):
    asoundrc_template_path = get_resource_path('template/asoundrc')
    asoundrc_dir = "{}/.config/alsa".format(get_moonlight_home_path())
    asoundrc_path = "{}/asoundrc".format(asoundrc_dir)

    service, device_name = get_kodi_audio_device()
    template = pathlib.Path(asoundrc_template_path).read_text()

    # Only set default device if a non-default device is configured
    if device_name == 'default':
        template = template.replace('%default_device%', '')
    else:
        template = template.replace('%default_device%', 'pcm.!default "{}"'.format(device_name))

    # Set the device
    template = template.replace('%device%', device_name)

    for speakers in [6, 8]:
        for speaker in range(speakers):
            # Get setting id and channel
            setting_id = 'alsa_surround_{}1_{}'.format(speakers - 1, speaker)
            template_var = '%{}%'.format(setting_id)
            channel = addon.getSetting(setting_id)

            # Replace template var
            template = template.replace(template_var, channel)

    # Ensure dir exists
    if not os.path.exists(asoundrc_dir):
        os.mkdir(asoundrc_dir)

    # Write new config to asoundrc file
    pathlib.Path(asoundrc_path).write_text(template)
    xbmc.log('New ALSA config file written to {}'.format(asoundrc_path), xbmc.LOGINFO)


def get_resource_path(sub_path):
    return translatePath(pathlib.Path(__file__).parent.absolute().__str__() + '/resources/' + sub_path)


def get_addon_data_path(sub_path=''):
    return translatePath('special://profile/addon_data/plugin.program.moonlight-qt' + sub_path)


def get_moonlight_home_path():
    return "{}/moonlight-home".format(get_addon_data_path())


def is_moonlight_installed():
    return os.path.isfile(get_addon_data_path('/moonlight-qt/bin/moonlight-qt'))


def get_kodi_setting(setting):
    request = {
        'jsonrpc': '2.0',
        'method': 'Settings.GetSettingValue',
        'params': {'setting': setting},
        'id': 1
    }
    response = json.loads(xbmc.executeJSONRPC(json.dumps(request)))
    return response['result']['value']


def set_kodi_setting(setting, value):
    request = {
        'jsonrpc': '2.0',
        'method': 'Settings.SetSettingValue',
        'params': {'setting': setting, 'value': value},
        'id': 1
    }
    json.loads(xbmc.executeJSONRPC(json.dumps(request)))


def get_kodi_audio_device():
    audio_device = get_kodi_setting('audiooutput.audiodevice').split(':', 1)

    if audio_device[1]:
        # Remove breaking part of the device name (Kodi 21)
        audio_device[1] = re.sub('\\|.*', '', audio_device[1])

    if audio_device[1][0] == '@':
        # Replace @ with default device
        audio_device[1] = audio_device[1].replace('@:', 'sysdefault:').replace(',DEV=0', '')

    return audio_device
