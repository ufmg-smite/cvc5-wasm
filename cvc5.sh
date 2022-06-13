# This script is responsible for
#

# Dirs:
BASE_DIR=$(pwd)
DEP_DIR=$BASE_DIR/deps/
CVC5_DIR=${DEP_DIR}cvc5/
EMSDK_DIR=${DEP_DIR}emsdk/
GMP_DIR=${DEP_DIR}gmp-6.1.2/
INCLUDE_DIR=${DEP_DIR}include/
# Other vars:
OPTIMIZATION=1
CORES_TO_COMPILE=16
LOG_FILE=$BASE_DIR/out.log
>$LOG_FILE

echo "---------------"
echo "- Basic deps "
echo "---------------"
{
    # sudo yum check-update
    # sudo yum groupinstall 'Development Tools'
    # sudo yum install python3 git cmake lzip
    echo ""
} >> "$LOG_FILE" 2>&1

echo ""
echo "---------------"
echo "- Downloading deps"
echo "---------------"
cd $DEP_DIR

echo "   ---EMSDK";{
    git clone https://github.com/emscripten-core/emsdk.git
}>> "$LOG_FILE" 2>&1

echo "   ---CVC5";{
    git clone https://github.com/cvc5/cvc5
}>> "$LOG_FILE" 2>&1

echo "   ---ANTLR";{
    echo "Cloning into 'ANTLR'..."
    wget --quiet -O /tmp/libantlr3c-3.4.tar.gz http://www.antlr3.org/download/C/libantlr3c-3.4.tar.gz
    tar -xf /tmp/libantlr3c-3.4.tar.gz -C "$DEP_DIR"
    rm /tmp/libantlr3c-3.4.tar.gz
}>> "$LOG_FILE" 2>&1

echo "   ---GMP";{
    echo "Cloning into 'GMP'..."
    wget --quiet -O /tmp/gmp-6.1.2.tar.xz https://gmplib.org/download/gmp/gmp-6.1.2.tar.xz
    tar -xf /tmp/gmp-6.1.2.tar.xz -C "$DEP_DIR"
    rm /tmp/gmp-6.1.2.tar.xz
}>> "$LOG_FILE" 2>&1

#Optei por n compilar o cln pq ele é so outra opção pro gmp e não é do meu interesse

echo ""
echo "---------------"
echo "- Building deps"
echo "---------------"

echo "   ---Emscripten"; {
    echo ""
    echo "Building Emscripten:"
    echo ""
    cd ${DEP_DIR}emsdk/
    git pull
    ./emsdk install latest
    ./emsdk activate latest
    source ./emsdk_env.sh
} >> "$LOG_FILE" 2>&1

echo '   ---GMP'; {
    echo ""
    echo "Building GMP:"
    echo ""
    cd ${GMP_DIR}
    # emconfigure ./configure --with-pic --disable-assembly --disable-fft --disable-shared
    emconfigure ./configure --disable-assembly --host none --enable-cxx
    emmake make -j${CORES_TO_COMPILE}
} >> "$LOG_FILE" 2>&1

echo '* ANTLR C runtime: configure'; {
    echo ""
    echo "Building Emscripten:"
    echo ""
    emconfigure ./configure --with-pic --disable-abiflags --disable-antlrdebug --disable-64bit --disable-shared
    emmake make -j${CORES_TO_COMPILE}
} >> "$LOGFILE" 2>&1

echo '   ---CVC5'; {   
    cd ${DEP_DIR}cvc5/
} >> "$LOG_FILE" 2>&1

mkdir -p "${INCLUDE_DIR}"
# ln -s /usr/include/boost/ "${INCLUDE_DIR}"

#Ainda fazer
CVC4_CONFIGURE_OPTS=(--with-antlr-dir="${ANTLRC_ROOT}" --with-boost="${INCLUDE_ROOT}"
                     --enable-static --enable-static-binary --enable-static-boost
                     --disable-maintainer-mode --disable-doxygen-doc
                     --disable-tracing --disable-assertions
                     --disable-debug-symbols --disable-unit-testing
                     --disable-thread-support --enable-language-bindings=
                     # --disable-statistics --disable-replay  --disable-proof  --disable-dumping
                     --with-build=production)

CVC4_CONFIGURE_ENV=(ANTLR="$(which antlr3.2)"
                    CPPFLAGS="-I${LIBGMP_ROOT} -I${ANTLRC_ROOT}"
                    LDFLAGS="-L${LIBGMP_ROOT}.libs -L${ANTLRC_ROOT}.libs")