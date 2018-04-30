# brainfuck compiler by shell script

このプログラムは、Brainfuck のコンパイラです。
ただし、フルセットのコンパイラではなく、LLVMのフロントエンドになっています。

使用例は以下のような感じ。

```shell-session
$ ./bfc.sh hello_world.bf
$ clang hello_world.ll -o hello_world
$ ./hello_world
```

ついでに、Brainfuck を C 言語に変換するトランスパイラ(トランスレーター)もあります。

```shell-session
$ ./bf2c.sh hello_world.bf
$ gcc hello_world.c -o hello_world
$ ./hello_world
```
