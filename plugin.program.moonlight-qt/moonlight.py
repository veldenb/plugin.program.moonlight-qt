from subprocess import Popen, PIPE, STDOUT
import os
import pathlib
import xbmc
import xbmcgui


def launch(hostname=None, game_name=None):
    launch_command = 'systemd-run bash ' + get_resources_path() + 'bin/launch_moonlight-qt.sh'

    # check if moonlight is installed and offer to install
    if is_moonlight_installed() is False:
        update_moonlight()

    # If moonlight is still not installed abort
    if is_moonlight_installed() is False:
        dialog = xbmcgui.Dialog()
        dialog.ok('Launching Moonlight', 'Moonlight not installed, aborting launch!')
        return

    # Check is at least a host is set
    args = ''
    if hostname and game_name:
        args = ' stream "{}" "{}"'.format(hostname, game_name)

    # Prepare the command
    command = launch_command + args

    # Log the command so debugging problems is easier
    xbmc.log(msg='Launching moonlight-qt: ' + command, level=xbmc.LOGINFO)

    # Show a dialog
    launch_label = 'Moonlight'
    if game_name:
        launch_label = game_name

    p_dialog = xbmcgui.DialogProgress()
    p_dialog.create('Launching Moonlight', 'Starting ' + launch_label + '...')
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
    dialog.ok('Launching Moonlight', 'Launching failed!')


def update_moonlight():
    install_label = 'install'
    if is_moonlight_installed():
        install_label = 'update to'

    c_dialog = xbmcgui.Dialog()
    confirm_update = c_dialog.yesno(
        'Install Moonlight',
        'Do you want {} the latest version of Moonlight? This wil take a few minutes.'.format(install_label)
    )

    if confirm_update is False:
        return

    p_dialog = xbmcgui.DialogProgress()
    p_dialog.create('Updating Moonlight', 'Updating Moonlight using Docker, this will take a while...')

    xbmc.log(msg='Updating moonlight-qt...', level=xbmc.LOGINFO)

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

    finish_label = 'failed: {}'.format(line.decode())
    if p.returncode == 0 and is_moonlight_installed():
        finish_label = 'finished'

    dialog = xbmcgui.Dialog()
    dialog.ok('Updating Moonlight', 'Update {}'.format(finish_label))


def get_resources_path():
    return pathlib.Path(__file__).parent.absolute().__str__() + '/resources/'


def is_moonlight_installed():
    return os.path.isfile(get_resources_path() + 'lib/moonlight-qt/bin/moonlight-qt')
