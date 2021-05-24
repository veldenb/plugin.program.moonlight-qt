from subprocess import Popen, PIPE, STDOUT
import os
import pathlib
import xbmc
import xbmcgui


def launch(addon, hostname=None, game_name=None):
    launch_command = 'systemd-run bash ' + get_resources_path() + 'bin/launch_moonlight-qt.sh'

    # check if moonlight is installed and offer to install
    if is_moonlight_installed() is False:
        update(addon)

    # If moonlight is still not installed abort
    if is_moonlight_installed() is False:
        dialog = xbmcgui.Dialog()
        dialog.ok(addon.getLocalizedString(30200), addon.getLocalizedString(30201))
        return

    # Check is at least a host is set
    args = ''
    if hostname and game_name:
        args = ' stream "{}" "{}"'.format(hostname, game_name)

    # Prepare the command
    command = launch_command + args

    # Log the command so debugging problems is easier
    xbmc.log('Launching moonlight-qt: ' + command, xbmc.LOGINFO)

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

    xbmc.log('Updating moonlight-qt...', xbmc.LOGINFO)

    # This is an estimate of how many lines of output there should be to guess the progress
    line_max = 1556
    line_nr = 1
    line = ''

    p = Popen('bash ' + get_resources_path() + 'build/build.sh', stdout=PIPE, stderr=STDOUT, shell=True)
    for line in p.stdout:
        percent = int(round(line_nr / line_max * 100))
        p_dialog.update(percent)
        line_nr += 1
    p.wait()

    # Log update
    xbmc.log('Updating moonlight-qt finished with {} lines of output and exit-code {}'.format(
        line_nr.__str__(), p.returncode.__str__()
    ), xbmc.LOGINFO)

    # Close the progress bar
    p_dialog.close()

    if p.returncode == 0 and is_moonlight_installed():
        finish_label = addon.getLocalizedString(30106)
    else:
        finish_label = addon.getLocalizedString(30105) % {'error_msg': line.decode()}

    dialog = xbmcgui.Dialog()
    dialog.ok(addon.getLocalizedString(30103), finish_label)


def get_resources_path():
    return pathlib.Path(__file__).parent.absolute().__str__() + '/resources/'


def is_moonlight_installed():
    return os.path.isfile(get_resources_path() + 'lib/moonlight-qt/bin/moonlight-qt')
