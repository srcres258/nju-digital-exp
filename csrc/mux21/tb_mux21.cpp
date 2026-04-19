#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vmux21.h"

VerilatedContext *contextp = nullptr;
VerilatedVcdC *tfp = nullptr;

static Vmux21 *top = nullptr;

void stepAndDumpWave() {
    top->eval();
    contextp->timeInc(1);
    tfp->dump(contextp->time());
}

void simInit() {
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    top = new Vmux21;
    contextp->traceEverOn(true);
    top->trace(tfp, 0);
    tfp->open("dump.vcd");
}

void simExit() {
    stepAndDumpWave();
    tfp->close();

    delete top;
    delete tfp;
    delete contextp;
}

int main() {
    // --- 开始仿真 ---
    simInit();

    // 将s、a、b均初始化为0
    top->s = 0;
    top->a = 0;
    top->b = 0;
    stepAndDumpWave();

    // 将b改为1,s、a的值不变，继续保持0
    top->b = 1;
    stepAndDumpWave();

    // 将a、b分别改为1、0,s的值比不安
    top->a = 1;
    top->b = 0;
    stepAndDumpWave();

    // 将b改为1,s、a的值不变，维持10个时间单位
    top->b = 1;
    stepAndDumpWave();

    // 将s、a、b分别变为1、0、0,维持10个时间单位
    top->s = 1;
    top->a = 0;
    top->b = 0;
    stepAndDumpWave();

    top->b = 1;
    stepAndDumpWave();

    top->a = 1;
    top->b = 0;
    stepAndDumpWave();

    top->b = 1;
    stepAndDumpWave();

    // --- 结束仿真 ---
    simExit();

    return 0;
}
