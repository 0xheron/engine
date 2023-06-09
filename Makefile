TARGET_EXEC = libRenderer.a
CC = clang++
LD = ar

SRC = $(wildcard src/*.cpp) $(wildcard src/**/*.cpp) $(wildcard src/**/**/*.cpp) $(wildcard src/**/**/**/*.cpp)
OBJ = $(SRC:.cpp=.o)
ASM = $(SRC:.cpp=.S)
BIN = bin
LIBS = lib/bgfx/.build/linux64_gcc/bin/libbgfxDebug.a lib/bgfx/.build/linux64_gcc/bin/libbxDebug.a lib/bgfx/.build/linux64_gcc/bin/libbimgDebug.a lib/bgfx/.build/linux64_gcc/bin/libbimg_decodeDebug.a lib/glfw/build/src/libglfw3.a -lGL -lX11 -lpthread -ldl -lrt

INC_DIR_SRC = -Isrc 
INC_DIR_LIB = -Ilib -Ilib/json/single_include -Ilib/bgfx/include -Ilib/bimg/include -Ilib/bx/include -Ilib/glfw/include -Ilib/OBJ-Loader/include -Ilib/cgltf/include -Ilib/glm/include

DEBUGFLAGS = $(INC_DIR_SRC) $(INC_DIR_LIB) -Wall -g -DDEBUG=1
RELEASEFLAGS = $(INC_DIR_SRC) $(INC_DIR_LIB) -O2
ASMFLAGS = $(INC_DIR_SRC) $(INC_DIR_LIBS) -Wall
LDFLAGS = rcs 

.PHONY: all clean  

all: clean shaders
	$(MAKE) -j8 bld
	$(MAKE) link

dirs:
	mkdir -p ./$(BIN)

link: $(OBJ)
	$(AR) $(LDFLAGS) $(BIN)/$(TARGET_EXEC) $^ 

bld: 
	$(MAKE) dirs
	$(MAKE) obj

obj: $(OBJ)

asm: cleanassembly $(ASM)

%.o: %.cpp
	$(CC) -std=c++20 -o $@ -c $< $(RELEASEFLAGS)

%.S: %.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	@echo 'Building ASM'
	$(CC) -std=c++20 -S -O -o $@ -c $< $(ASMFLAGS)
	@echo 'Finished building: $<'
	@echo ' '

%.S: %.c 
	./$(BIN)/$(TARGET_EXEC) $< $@

shaders:
	$(MAKE) -C resources/shaders

run:
	./$(BIN)/$(TARGET_EXEC) 

debug:
	lldb ./$(BIN)/$(TARGET_EXEC)

clean:
	clear
	rm -rf $(BIN) $(OBJ)

cleanassembly:
	rm -rf $(ASM)
