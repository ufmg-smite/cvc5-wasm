# This script is responsible for
#

# Dirs:
BASE_DIR=$(pwd)
DEP_DIR=$BASE_DIR/deps/
CVC5_DIR=${DEP_DIR}cvc5/
EMSDK_DIR=${DEP_DIR}emsdk/
LOG_DIR=${BASE_DIR}/logs/
# Other vars:
CORES_TO_COMPILE=6
BUILD_NAME=production

cd $LOG_DIR
rm *

echo ""
echo "-------------------------------"
echo "- Downloading deps"
echo "-------------------------------"
cd $DEP_DIR

echo "   ---EMSDK";{
    echo ""
    echo "Downloading Emscripten:"
    echo ""
    git clone https://github.com/emscripten-core/emsdk.git
}>> "${LOG_DIR}download.log" 2>&1

echo "   ---CVC5";{
    echo ""
    echo "Downloading CVC5:"
    echo ""
    # Temporarily will be fetched from my personal fork
    git clone -b wasm https://github.com/vinciusb/cvc5
}>> "${LOG_DIR}download.log" 2>&1

#Optei por n compilar o cln pq ele é so outra opção pro gmp e não é do meu interesse

echo ""
echo "-------------------------------"
echo "- Configuring deps"
echo "-------------------------------"

echo "   ---Emscripten"; {
    echo ""
    echo "Configuring Emscripten:"
    echo ""
    cd ${EMSDK_DIR}
    git pull
    ./emsdk install latest
    ./emsdk activate latest
    source ./emsdk_env.sh
} >> "${LOG_DIR}config.log" 2>&1

echo "   ---CVC5"; {
    echo ""
    echo "Configuring CVC5:"
    echo ""

    EMCC_WASM_FLAGS=(-s EXPORTED_FUNCTIONS=_main -s EXPORTED_RUNTIME_METHODS=ccall,cwrap -s INCOMING_MODULE_JS_API=arguments)

    CVC5_CONFIGURE_OPTS=(--static --static-binary --no-tracing --no-assertions
                        --no-debug-symbols --no-unit-testing --name=${BUILD_NAME} --auto-download
                        )
                        #  --no-poly)

    CVC5_CONFIGURE_ENV=(LDFLAGS="${EMCC_WASM_FLAGS[@]}")

    cd ${CVC5_DIR}
    env "${CVC5_CONFIGURE_ENV[@]}" emconfigure ./configure.sh "${CVC5_CONFIGURE_OPTS[@]}"
} >> "${LOG_DIR}config.log" 2>&1


echo ""
echo "-------------------------------"
echo "- Building CVC5"
echo "-------------------------------"

echo '   ---CVC5'; {
    cd ./${BUILD_NAME}
    emmake make -j${CORES_TO_COMPILE}
} >> "${LOG_DIR}build.log" 2>&1

cp ${CVC5_DIR}${BUILD_NAME}/bin/cvc5.wasm ${BASE_DIR}/cvc5.wasm