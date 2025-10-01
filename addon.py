import configparser
import moonlight
import re
import sys
import urllib.parse
import xbmc
import xbmcaddon
import xbmcgui
import xbmcplugin
from xbmcvfs import translatePath


def build_url(query):
    return base_url + '?' + urllib.parse.urlencode(query)


def get_addon_path(sub_path):
    return translatePath(addon.getAddonInfo('path') + sub_path)


def get_addon_data_path(sub_path=''):
    return translatePath('special://profile/addon_data/plugin.program.moonlight-qt' + sub_path)


def get_resource_path(sub_path):
    return get_addon_path('/resources' + sub_path)


def get_icon_path():
    return get_resource_path('/icon.png')


def get_poster_path():
    return get_resource_path('/poster.jpg')


def get_fanart_path():
    return get_resource_path('/fanart.jpg')


def get_boxart_path(host, app):
    sampleBoxart = '/moonlight-home/.cache/Moonlight Game Streaming Project/Moonlight/boxart/{}/{}.png'.format(
        host.get('uuid'), app.get('id')
    )
    return get_addon_data_path(sampleBoxart)


def get_moonlight_config():
    # Load config
    moonlight_full_config_path = get_addon_data_path(
        '/moonlight-home/.config/Moonlight Game Streaming Project/Moonlight.conf'
    )
    return parse_moonlight_config(moonlight_full_config_path)


def parse_moonlight_config(moonlight_config_file):
    config = configparser.ConfigParser(interpolation=None)
    config.read(moonlight_config_file)

    parsedOptions = {}
    for section in config.sections():
        parsedOptions[section] = {}

        for option in config.options(section):
            options = option.split('\\')
            optionValue = config.get(section, option)

            # It would be nice if the code below could be simplified, essentially you want to convert and merge
            # \\a\\b\\c\\d1\\val1 and \\a\\b\\c\\d2\\val2 to { a: { b: { c: { d1: val1, d2: val2 }}}}
            if len(options) == 4:
                o1, o2, o3, o4 = options

                if o1 not in parsedOptions[section]:
                    parsedOptions[section][o1] = {}

                if o2 not in parsedOptions[section][o1]:
                    parsedOptions[section][o1][o2] = {}

                if o3 not in parsedOptions[section][o1][o2]:
                    parsedOptions[section][o1][o2][o3] = {}

                parsedOptions[section][o1][o2][o3][o4] = optionValue
            elif len(options) == 3:
                o1, o2, o3 = options

                if o1 not in parsedOptions[section]:
                    parsedOptions[section][o1] = {}

                if o2 not in parsedOptions[section][o1]:
                    parsedOptions[section][o1][o2] = {}

                parsedOptions[section][o1][o2][o3] = optionValue
            elif len(options) == 2:
                o1, o2 = options

                if o1 not in parsedOptions[section]:
                    parsedOptions[section][o1] = {}

                parsedOptions[section][o1][o2] = optionValue
            elif len(options) == 1:
                o1 = options[0]
                parsedOptions[section][o1] = optionValue

    return parsedOptions


def show_hosts(handle, hosts):
    # Show hosts
    for tag_id in hosts:
        if 'apps' in hosts[tag_id]:
            host = hosts[tag_id]

            url = build_url({'mode': 'host', 'host_id': tag_id})
            li = xbmcgui.ListItem(host.get('hostname'))
            xbmcplugin.addDirectoryItem(handle, url, li, isFolder=True)


def show_moonlight(handle):
    url = build_url({'mode': 'launch'})
    li = xbmcgui.ListItem(addon.getLocalizedString(30001))
    icon = get_icon_path()
    li.setArt({
        'thumb': icon,
        'poster': get_poster_path(),
        'fanart': get_fanart_path(),
        'icon': icon
    })
    xbmcplugin.addDirectoryItem(handle, url, li)

def get_groups(hosts, host_id):
    host = hosts[host_id]
    groups = []
    if 'apps' in host:
        for app_id, app in host['apps'].items():
            if 'name' in app:
                match = re.match("^\{(.*)\}", app.get('name'))
                if match:
                    group = match.group(1)
                    if group not in groups:
                        groups.append(group)
    return groups

def show_groups(handle, host_id, groups):
    # Show groups for host
    for group in groups:
        url = build_url({'mode': 'host', 'host_id': host_id, 'group': group})
        li = xbmcgui.ListItem(group)
        xbmcplugin.addDirectoryItem(handle, url, li, isFolder=True)

def show_games(handle, hosts, host_id, groups, group):
    # Show games for host
    host = hosts[host_id]

    if 'apps' in host:
        for app_id, app in host['apps'].items():
            if 'name' in app:
                if group is not None and group in groups:
                    match = re.match("^\{(.*)\}(.*)", app.get('name'))
                    if match is None or match.group(1) != group:
                        continue
                    name = match.group(2).strip()
                else:
                    name = app.get('name')

                url_dict = {'mode': 'launch', 'host_id': host_id, 'game_id': app_id}
                url = build_url(url_dict)
                boxart = get_boxart_path(host, app)
                li = xbmcgui.ListItem()
                li.setLabel(name)
                li.setArt({
                    'thumb': boxart,
                    'poster': boxart
                })
                xbmcplugin.addDirectoryItem(handle, url, li)


def show_gui(handle, mode, host_id, group, game_id):
    # Get hosts from moonlight config
    hosts = get_moonlight_config().get('hosts')

    if mode is None:

        if hosts:
            # If there is only one host and a size-item then show the games immediately
            if len(hosts) == 2:
                host_id = list(hosts.keys())[0]
                groups = get_groups(hosts, host_id)
                if len(groups) > 0 and group is None:
                    # Show groups
                    show_groups(handle, host_id, groups)
                else:
                    # Show games
                    show_games(handle, hosts, host_id, groups, group)
            else:
                show_hosts(handle, hosts)

        # Always show Moonlight
        show_moonlight(handle)

        # Finish list
        xbmcplugin.endOfDirectory(handle)

    elif mode == 'host' and host_id in hosts:

        # Retrieve groups
        groups = get_groups(hosts, host_id)

        if len(groups) > 0 and group is None:
            # Show groups
            show_groups(handle, host_id, groups)
            show_moonlight(handle)
        else:
            # Show games
            show_games(handle, hosts, host_id, groups, group)
            if len(groups) == 0:
                show_moonlight(handle)

        # Finish list
        xbmcplugin.endOfDirectory(handle)

    elif mode == 'launch':
        # Launch game on host
        if host_id is not None and game_id is not None:
            host_name = hosts[host_id]['localaddress']
            game_name = hosts[host_id]['apps'][game_id]['name']

            # Launch game
            moonlight.launch(addon, host_name, game_name)
        else:
            # Launch Moonlight
            moonlight.launch(addon)

    elif mode == 'update':
        # Update Moonlight
        moonlight.update(addon)

    elif mode == 'speaker_test_51':
        # Test surround 5.1 speakers
        moonlight.speaker_test(addon, 6)

    elif mode == 'speaker_test_71':
        # Test surround 7.1 speakers
        moonlight.speaker_test(addon, 8)

    else:
        xbmc.log('Unknown GUI mode: {}'.format(mode), xbmc.LOGDEBUG)

if __name__ == '__main__':

    # Arguments
    base_url = sys.argv[0]
    addon_handle = int(sys.argv[1])
    args = urllib.parse.parse_qs(sys.argv[2][1:])

    # Configure addon
    addon = xbmcaddon.Addon()
    if addon_handle != -1:
        xbmcplugin.setContent(addon_handle, 'games')

    # Debug stuff
    # See https://kodi.wiki/view/Audio-video_add-on_tutorial
    # xbmc.log(sys.argv.__str__(), xbmc.LOGDEBUG)
    # xbmc.log(args.__str__(), xbmc.LOGDEBUG)
    # xbmc.log('CONFIG: ' + moonlight_config.__str__(), level=xbmc.LOGDEBUG)

    page_mode = args.get('mode', None)
    if page_mode is not None:
        page_mode = page_mode[0]

    page_host_id = args.get('host_id', None)
    if page_host_id is not None:
        page_host_id = page_host_id[0]

    page_group = args.get('group', None)
    if page_group is not None:
        page_group = page_group[0]

    page_game_id = args.get('game_id', None)
    if page_game_id is not None:
        page_game_id = page_game_id[0]

    # Show GUI
    show_gui(addon_handle, page_mode, page_host_id, page_group, page_game_id)

# Parsed config example
# example_moonlight_config = {
#     'General': {
#         'abstouchmode': 'true',
#         'audiocfg': '1',
#         'backgroundgamepad': 'false',
#         'bitrate': '20000',
#         'capturesyskeys': '0',
#         'certificate': '"@ByteArray(-----BEGIN CERTIFICATE-----\\nABCDEFFF\\nABCDEF=\\n-----END CERTIFICATE-----\\n)"',
#         'connwarnings': 'true',
#         'defaultver': '1',
#         'detectnetblocking': 'false',
#         'fps': '60',
#         'framepacing': 'false',
#         'gameopts': 'false',
#         'gamepadmouse': 'true',
#         'height': '1080',
#         'hostaudio': 'true',
#         'key': '@ByteArray(-----BEGIN PRIVATE KEY-----\\nABCDEFFFFF\\ABCDEF\\n-----END PRIVATE KEY-----\\n)',
#         'language': '0',
#         'latestsupportedversion-v1': '99.99.99.99',
#         'mdns': 'false',
#         'mouseacceleration': 'false',
#         'multicontroller': 'true',
#         'muteonfocusloss': 'false',
#         'packetsize': '0',
#         'quitappafter': 'true',
#         'reversescroll': 'false',
#         'richpresence': 'true',
#         'swapfacebuttons': 'false',
#         'swapmousebuttons': 'false',
#         'uidisplaymode': '0',
#         'unsupportedfps': 'false',
#         'videocfg': '0',
#         'videodec': '0',
#         'vsync': 'false',
#         'width': '1920',
#         'windowmode': '0'
#     },
#     'gcmapping': {
#         '1': {'guid': '00001000010000100001000010000100',
#               'mapping': '"dev:xb1:Some joypad,platform:Linux,b:b1,y:b0,x:b3,start:b9,back:b8,leftstick:b10,rightstick:b11,leftshoulder:b6,rightshoulder:b7,dpup:h0.1,dpleft:h0.8,dpdown:h0.4,dpright:h0.2,leftx:a0,lefty:a1,rightx:a3,righty:a2,lefttrigger:b4,righttrigger:b5,a:b2,"'},
#         'size': '1'},
#     'hosts': {
#         '1': {
#             'apps': {
#                 '1': {
#                     'appcollector': 'false',
#                     'directlaunch': 'false',
#                     'hdr': 'false',
#                     'hidden': 'false',
#                     'id': '1234567890',
#                     'name': 'Some game 1'
#                 },
#                 '2': {
#                     'appcollector': 'false',
#                     'directlaunch': 'false',
#                     'hdr': 'true',
#                     'hidden': 'false',
#                     'id': '0123456789',
#                     'name': 'Some game 2'
#                 }, 'size': '2'
#             },
#             'customname': 'false',
#             'hostname': 'MYHOSTNAME',
#             'ipv6address': '1000:0000:11:2:33:4444:5555:6666',
#             'localaddress': '192.168.0.2',
#             'mac': '@ByteArray(AA\\0\\aa0A])',
#             'manualaddress': '192.168.1.141',
#             'remoteaddress': '123.123.123.123',
#             'srvcert': '"@ByteArray(-----BEGIN CERTIFICATE-----\\nABCDEFFFFFF=\\n-----END CERTIFICATE-----\\n)"',
#             'uuid': 'aaaaaaaa-1234-aaaa-1234-aaaaaaaaaaaa'
#         },
#         'size': '1'
#     }
# }
