import json
from subprocess import Popen, PIPE, STDOUT
import os
import pathlib
import xbmc
import xbmcgui
from xbmcvfs import translatePath


def launch(addon, hostname=None, game_name=None):
    # check if moonlight is installed and offer to install
    if is_moonlight_installed() is False:
        update(addon)

    # If moonlight is still not installed abort
    if is_moonlight_installed() is False:
        dialog = xbmcgui.Dialog()
        dialog.ok(addon.getLocalizedString(30200), addon.getLocalizedString(30201))
        return

    # Initialise environment vars
    env_vars = [f'--setenv=ADDON_PROFILE_PATH="{get_addon_data_path()}"']
    moonlight_args = []

    # Resolve audio output device
    try:
        service, device_name = get_kodi_setting('audiooutput.audiodevice').split(':', 1)
        if service == 'ALSA':
            # Disable PulseAudio output by using a Moonlight environment variable
            env_vars.append('--setenv=PULSE_SERVER="none"')

            # When a specific audio device is used pass it through using an environment variable
            if device_name != '@':
                env_vars.append(f'--setenv=ALSA_PCM_NAME="{device_name}"')
        elif service == 'PULSE':
            # Tell pulse to use a specific device configured in Kodi
            env_vars.append(f'--setenv=PULSE_SINK="{device_name}"')
        else:
            # Raise a warning when ALSA and PULSE are not detected
            raise RuntimeError(f'Audio service {service} not supported')
    except Exception as err:
        xbmc.log(f'Failed to resolve audio output device, audio within Moonlight might not work: {err}', xbmc.LOGWARNING)

    launch_command = 'systemd-run {} bash {}'.format(
        ' '.join(env_vars),
        get_resource_path('bin/launch_moonlight-qt.sh')
    )

    # Check if at least a host is set
    if hostname and game_name:
        moonlight_args.extend(['stream', f'"{hostname}"', f'"{game_name}"'])

    # Prepare the command
    command = f'{launch_command} ' + ' '.join(moonlight_args)

    # Log the command so debugging problems is easier
    xbmc.log('Launching moonlight-qt: ' + command, xbmc.LOGDEBUG)

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

    # If the command was successful wait for moonlight to shutdown kodi
    if exitcode == 0:
        xbmc.sleep(1000)

    # If moonlight did not start notify the user
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

    cmd = 'ADDON_PROFILE_PATH="{}" bash {}'.format(get_addon_data_path(), get_resource_path('build/build.sh'))
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

    # Close the progress bar
    p_dialog.close()

    if p.returncode == 0 and is_moonlight_installed():
        finish_label = addon.getLocalizedString(30106)
    else:
        finish_label = addon.getLocalizedString(30105) % {'error_msg': line.decode()}

    dialog = xbmcgui.Dialog()
    dialog.ok(addon.getLocalizedString(30103), finish_label)


def get_resource_path(sub_path):
    return translatePath(pathlib.Path(__file__).parent.absolute().__str__() + '/resources/' + sub_path)


def get_addon_data_path(sub_path=''):
    return translatePath('special://profile/addon_data/plugin.program.moonlight-qt' + sub_path)


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
