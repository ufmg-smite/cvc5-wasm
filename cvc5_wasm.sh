################################################################################
# Description: This script allows the user to compile CVC5 
#               (https://github.com/cvc5/cvc5) to a WebAssembly version. The 
#               user can select between WASM, JS or HTML extension.
# Last update: xx/xx/2022
# Author: Vinícius Braga Freire (vinicius.braga.freire@gmail.com)
################################################################################

# Dirs:
BASE_DIR=$(pwd)
DEP_DIR=$BASE_DIR/deps/
CVC5_DIR=${DEP_DIR}cvc5/
EMSDK_DIR=${DEP_DIR}emsdk/
LOG_DIR=${BASE_DIR}/logs/
# Other vars:
CORES_TO_COMPILE=6
BUILD_NAME=production
# Log dir:
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

    # The flags used in the link of the final binary. These are the em++ flags.
    EMCC_WASM_FLAGS=(   
                        # -s EXPORTED_FUNCTIONS=_main 
                        -s EXPORTED_RUNTIME_METHODS=ccall,cwrap 
                        -s INCOMING_MODULE_JS_API=arguments 
                        -s INVOKE_RUN=1 
                        -s EXIT_RUNTIME=0
                        -s ENVIRONMENT=web 
                        -s MODULARIZE
                        )

    # This just make sure that the flags will be passed to the link process
    CVC5_CONFIGURE_ENV=(LDFLAGS="${EMCC_WASM_FLAGS[@]}")

    # These are the CVC5 configure flags
    CVC5_CONFIGURE_OPTS=(   
                            --static    # It's obligatory to compile statically
                            --static-binary
                            --no-tracing --no-assertions
                            --no-debug-symbols --no-unit-testing 
                            --name=${BUILD_NAME} --auto-download
                            --wasm=JS   # Flag to sign whether will be a 
                                        # WebAssembly compilation and which
                                        # extension will be used
                                        # (OFF, WASM, JS or HTML).
                        )
                        #  --no-poly)

    # Configure the CVC5
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

# Copies the binary from the cvc5 folder to the root directory of this project.
# All the result files from the compilation process are generated in the 
# ${CVC5_DIR}${BUILD_NAME}/bin/ directory.
cp ${CVC5_DIR}${BUILD_NAME}/bin/cvc5.wasm ${BASE_DIR}/cvc5.wasm