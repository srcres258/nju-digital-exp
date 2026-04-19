#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vmux41.h"

VerilatedContext *contextp = nullptr;
VerilatedVcdC *tfp = nullptr;

static Vmux41 *top = nullptr;

void stepAndDumpWave() {
    top->eval();
    contextp->timeInc(1);
    tfp->dump(contextp->time());
}

void simInit() {
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    top = new Vmux41;
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

    top->s = 0b00;
    top->a = 0b1110;
    stepAndDumpWave();

    top->a = 0b0001;
    stepAndDumpWave();

    top->s = 0b01;
    top->a = 0b1110;
    stepAndDumpWave();

    top->a = 0b0010;
    stepAndDumpWave();

    top->s = 0b10;
    top->a = 0b1010;
    stepAndDumpWave();

    top->a = 0b0100;
    stepAndDumpWave();

    top->s = 0b11;
    top->a = 0b0111;
    stepAndDumpWave();

    top->a = 0b1001;
    stepAndDumpWave();

    simExit();

    return 0;
}
