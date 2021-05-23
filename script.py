import moonlight
import sys
import xbmcaddon

# Add-on launch as script/program
if __name__ == '__main__':
    if len(sys.argv) > 1:
        argument = sys.argv[1]
    else:
        argument = ''

    if argument == "UpdateMoonlight":
        moonlight.update_moonlight()
    else:
        # Run moonlight-qt
        moonlight.launch()
