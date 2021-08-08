LIB_PATH="$MOONLIGHT_PATH/lib"

# Setup library locations
export LD_LIBRARY_PATH=/usr/lib/:$LIB_PATH:$LD_LIBRARY_PATH
export QML_IMPORT_PATH=$LIB_PATH/qt5/qml/
export QML2_IMPORT_PATH=$LIB_PATH/qt5/qml/
export QT_QPA_PLATFORM_PLUGIN_PATH=$LIB_PATH/qt5/plugins/
