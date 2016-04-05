
#include <xs1.h>
#include <platform.h>
#include <print.h>
#include <spi.h>
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


DisplayContext dc;


void demoLines(client spi_master_if lcd){
    Point triangle[] = {{-2, -2}, {2, -2}, {0, 2}, {-2, -2}};
    Point points[4];
    Point at = {160, 120};

    lcd.clear(dc);

    lcd.drawText(dc, "Lines", 131, 0);

    lcd.setColor(dc, 0xffff00);
    for (int i = 0; i < 40; i++){
        for (int j=0; j<4; j++) {
            points[j].x = at.x + triangle[j].x*i;
            points[j].y = at.y + triangle[j].y*i;
        }
        lcd.drawPolyLine(dc, points, 4);
    }
    lcd.drawPolyLine(dc, points, 4);

    lcd.setColor(dc, 0xff0000);
    for (int x=0; x<=320; x+=10){
        lcd.drawLine(dc, 0, 0, x, 239);
    }
    lcd.setColor(dc, 0x0000ff);
    for (int x=319; x>=0; x-=10){
        lcd.drawLine(dc, 319, 0, x, 239);
    }
}


void demo(client spi_master_if lcd){
    out port * movable dcport_ptr = &dcport;

    lcd.init(dc, move(dcport_ptr), reset);
    lcd.setFont(dc,
                dejavu_sans_mono_book_16_font_lookup,
                dejavu_sans_mono_book_16_font_pixels);

    while(1) {
        demoLines(lcd);
        delay_microseconds(1000000);
        lcd.clear(dc);
        lcd.setColor(dc, 0xffff00);
        for (int x=0; x < 200; x+=120) {
            for (int y=0; y < 222; y += 18) {
                lcd.drawText(dc, "Test 1, 2, 3", x, y);
            }
        }
        delay_microseconds(1000000);
        lcd.clear(dc);
        for(int i=0; i<1500;i++) {
            lcd.setColor(dc, rand() & 0xffffff);
            lcd.drawRect(dc, rand()%320, rand()%240, rand()%100, rand()%100);
        }
        lcd.clear(dc);
        for(int i=0; i<200;i++) {
            lcd.setColor(dc, rand() & 0xffffff);
            lcd.drawFilledRect(dc, rand()%320, rand()%240, rand()%100, rand()%100);
        }
        lcd.clear(dc);
        for(int i=0; i<500;i++) {
            lcd.setColor(dc, rand() & 0xffffff);
            lcd.drawCircle(dc, rand()%320, rand()%240, rand()%100);
        }
        lcd.clear(dc);
        for(int i=0; i<120;i++) {
            lcd.setColor(dc, rand() & 0xffffff);
            lcd.drawFilledCircle(dc, rand()%320, rand()%240, rand()%60);
        }
    }
}


int main() {
    spi_master_if i_spi[1];
    par {
        demo(i_spi[0]);
        spi_master(i_spi, 1, p_sclk, p_mosi, p_miso , p_ss, 1, clk_spi);
    }
    return 0;
}
