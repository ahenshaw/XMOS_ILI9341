
#include <xs1.h>
#include <platform.h>
#include <print.h>
#include <spi.h>
#include "ILI9341.h"
#include <stdio.h>
#include <stdlib.h>
#include "lcd_interface.h"
#include "dejavu_sans_mono_book_16_font.h"


// LCD interface
out port reset              = on tile[0]: XS1_PORT_1J;
out port dcport             = on tile[0]: XS1_PORT_1K;

out port p_ss[1]            = on tile[0]:{XS1_PORT_1F};
out buffered port:32 p_mosi = on tile[0]: XS1_PORT_1H;
out buffered port:32 p_sclk = on tile[0]: XS1_PORT_1G;
in  buffered port:32 p_miso = on tile[0]: XS1_PORT_1E;
clock clk_spi               = on tile[0]: XS1_CLKBLK_1;

unsigned int z1 = 12345;
unsigned int z2 = 12345;
unsigned int z3 = 12345;
unsigned int z4 = 12345;

out port * movable dcport_p = &dcport;

DisplayContext dc;

void reset_panel() {
    reset <: 1;
    delay_microseconds(5000);
    reset <: 0;
    delay_microseconds(20000);
    reset <: 1;
    delay_microseconds(150000);
}


void test(client spi_master_if lcd){
    reset_panel();
    lcd.init(dc, move(dcport_p));
    lcd.setFont(dc,
                dejavu_sans_mono_book_16_font_lookup,
                dejavu_sans_mono_book_16_font_pixels);

    lcd.clear(dc);

    //lcd.drawText(dc, "Text Test", 110, 0);
    //char str[8];
    //for(int i=0; i<1000; i++) {
    //    sprintf(str, "%d", i);
    //    lcd.drawText(dc, str, 138, 20);
    //}
    lcd.drawLED(dc, 130, 30, 5);
    //lcd.drawText(dc, "    ", 138, 20);
    lcd.drawText(dc, "Testing", 110, 0);
    lcd.setColor(dc, 0xff0000);
    for (int x=0; x<=320; x+=10){
        lcd.drawLine(dc, 0, 0, x, 239);
    }
    lcd.setColor(dc, 0x0000ff);
    for (int x=319; x>=0; x-=10){
        lcd.drawLine(dc, 319, 0, x, 239);
    }

}

/*
void graphics(client spi_master_if lcd){
    int i;
    //247, 222

    reset_panel();
    lcd.initRegisters(dcport);

    while(1) {
        lcd.clear(dcport, 0);
        for(i=0; i < 20; i++){

            for (int x=0; x < 200; x+=120) {
                for (int y=0; y < 222; y += 18) {

                    lcd.drawString(dcport,
                                   "Test 1, 2, 3",
                                   x, y,
                                   rand() % 0xffffff, rand() % 0xffffff,
                                   dejavu_sans_mono_book_16_font_lookup,
                                   dejavu_sans_mono_book_16_font_pixels);

                }
            }
        }
        lcd.clear(dcport, 0);
        for(i=0; i<300;i++) {
            lcd.drawFilledRect(dcport, rand()%320, rand()%240, rand()%100, rand()%100, rand()%65535);
        }
        lcd.clear(dcport, 0);
        for(i=0; i<3000;i++) {
            lcd.drawRect(dcport, rand()%320, rand()%240, rand()%100, rand()%100, rand()%65535);
        }
        lcd.clear(dcport, 0);
        for(i=0; i<1000;i++) {
            lcd.drawCircle(dcport, rand()%320, rand()%240, rand()%100, rand()%65535);
        }
        lcd.clear(dcport, 0);
        for(i=0; i<200;i++) {
            lcd.drawFilledCircle(dcport, rand()%320, rand()%240, rand()%60, rand()%65535);
        }
    }

}
*/

int main() {
    spi_master_if i_spi[1];
    par {
        //graphics(i_spi[0]);
        test(i_spi[0]);
        spi_master(i_spi, 1,
            p_sclk, p_mosi, p_miso , p_ss, 1, clk_spi);
    }
    return 0;
}
