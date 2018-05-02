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

## 参考資料

* LLVM
  * コンパイラ基盤
  * [LLVM Language Reference Manual](http://llvm.org/docs/LangRef.html)
  * wikipedia - [LLVM](https://ja.wikipedia.org/wiki/LLVM)
  * 今回は LLVM API は使わずに、LLVM IRを直接出力するだけ
* Brainf*ck
  * 8種類の文字だけでコーディングできる言語
  * wikipedia [Brainfuck](https://ja.wikipedia.org/wiki/Brainfuck)
