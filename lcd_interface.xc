#include "spi.h"
#include "ILI9341_REGS.h"
#include "dejavu_sans_mono_book_16_font.h"
#include "lcd_interface.h"
#include <stdlib.h>
//#include "font.h"

#define FONT_HEIGHT 18

#define LCD_WIDTH 320
#define LCD_HEIGHT 240

#define SPI_SPEED 25000
#define SPI_MODE  SPI_MODE_1
#define SPI_DELAY 1
#define DEVICE_ID 0


#define COLOR(red, green, blue)   ((unsigned int)( (( red >> 3 ) << 11 ) | (( green >> 2 ) << 5  ) |  ( blue  >> 3 )))

#define COLOR24(color) ((unsigned int) ((( color >> 19 ) << 11 ) | ((( color >> 10 ) & 0x3f ) << 5  ) | (( color  >> 3 ) & 0x1f)))


extends client interface spi_master_if  : {



    uint16_t transfer16(client spi_master_if self, uint16_t value)
    {
        uint16_t data;
        data = self.transfer8(value >> 8);
        return (data << 8) && self.transfer8(value & 0xFF);
    }


    void writeBuffer(client spi_master_if self,
                     uint8_t buffer[],
                     int length)
    {
        int count = 0;
        while(count < length) {
            self.transfer8(buffer[count++]);
        }
    }

    void sendCommand(client spi_master_if self,
                     DisplayContext & dc,
                     uint8_t command)
    {
        *dc.dc_port <: 0;
        self.transfer8(command);
        *dc.dc_port <: 1;
    }

    uint8_t readRegister(client spi_master_if self,
                         DisplayContext & dc,
                         uint8_t addr, uint8_t xparam)
    {
        self.sendCommand(dc, 0xD9);   // ext command
        self.transfer8(0x10 + xparam);     // 0x11 is the first Parameter
        self.sendCommand(dc, addr);
        return self.transfer8(0);
    }

    void initRegisters(client spi_master_if self,
                       DisplayContext & dc)
    {
        self.begin_transaction(DEVICE_ID, SPI_SPEED, SPI_MODE);
        self.sendCommand(dc, 0xEF);
        self.transfer8(0x03);
        self.transfer8(0x80);
        self.transfer8(0x02);

        self.sendCommand(dc, 0xCF);
        self.transfer8(0x00);
        self.transfer8(0XC1);
        self.transfer8(0X30);

        self.sendCommand(dc, 0xED);
        self.transfer8(0x64);
        self.transfer8(0x03);
        self.transfer8(0X12);
        self.transfer8(0X81);

        self.sendCommand(dc, 0xE8);
        self.transfer8(0x85);
        self.transfer8(0x00);
        self.transfer8(0x78);

        self.sendCommand(dc, 0xCB);
        self.transfer8(0x39);
        self.transfer8(0x2C);
        self.transfer8(0x00);
        self.transfer8(0x34);
        self.transfer8(0x02);

        self.sendCommand(dc, 0xF7);
        self.transfer8(0x20);

        self.sendCommand(dc, 0xEA);
        self.transfer8(0x00);
        self.transfer8(0x00);

        self.sendCommand(dc, ILI9341_CMD_POWER_CONTROL_1);    //Power control
        self.transfer8(0x23);   //VRH[5:0]

        self.sendCommand(dc, ILI9341_CMD_POWER_CONTROL_2);    //Power control
        self.transfer8(0x10);   //SAP[2:0];BT[3:0]

        self.sendCommand(dc, ILI9341_CMD_VCOM_CONTROL_1);    //VCM control
        self.transfer8(0x3e);
        self.transfer8(0x28);

        self.sendCommand(dc, ILI9341_CMD_VCOM_CONTROL_2);    //VCM control2
        self.transfer8(0x86);

        self.sendCommand(dc, ILI9341_CMD_MEMORY_ACCESS_CONTROL);    // Memory Access Control
        self.transfer8(0xC8); //0x48

        self.sendCommand(dc, ILI9341_CMD_COLMOD_PIXEL_FORMAT_SET);
        self.transfer8(0x55);

        self.sendCommand(dc, ILI9341_CMD_FRAME_RATE_CONTROL_NORMAL);
        self.transfer8(0x00);
        self.transfer8(0x18);

        self.sendCommand(dc, ILI9341_CMD_DISPLAY_FUNCTION_CONTROL);    // Display Function Control
        self.transfer8(0x08);
        self.transfer8(0x82);
        self.transfer8(0x27);

        self.sendCommand(dc, ILI9341_CMD_ENABLE_3_GAMMA_CONTROL);    // Gamma Function Disable
        self.transfer8(0x00);

        self.sendCommand(dc, ILI9341_CMD_GAMMA_SET);    //Gamma curve selected
        self.transfer8(0x01);

        self.sendCommand(dc, ILI9341_CMD_POSITIVE_GAMMA_CORRECTION);    //Set Gamma
        self.transfer8(0x0F);
        self.transfer8(0x31);
        self.transfer8(0x2B);
        self.transfer8(0x0C);
        self.transfer8(0x0E);
        self.transfer8(0x08);
        self.transfer8(0x4E);
        self.transfer8(0xF1);
        self.transfer8(0x37);
        self.transfer8(0x07);
        self.transfer8(0x10);
        self.transfer8(0x03);
        self.transfer8(0x0E);
        self.transfer8(0x09);
        self.transfer8(0x00);

        self.sendCommand(dc, ILI9341_CMD_NEGATIVE_GAMMA_CORRECTION);    //Set Gamma
        self.transfer8(0x00);
        self.transfer8(0x0E);
        self.transfer8(0x14);
        self.transfer8(0x03);
        self.transfer8(0x11);
        self.transfer8(0x07);
        self.transfer8(0x31);
        self.transfer8(0xC1);
        self.transfer8(0x48);
        self.transfer8(0x08);
        self.transfer8(0x0F);
        self.transfer8(0x0C);
        self.transfer8(0x31);
        self.transfer8(0x36);
        self.transfer8(0x0F);

        self.sendCommand(dc, ILI9341_CMD_SLEEP_OUT);    //Exit Sleep
        self.end_transaction(SPI_DELAY);
        delay_microseconds(120000);

        self.begin_transaction(DEVICE_ID, SPI_SPEED, SPI_MODE);
        self.sendCommand(dc, ILI9341_CMD_DISPLAY_ON);    //Display on
        self.end_transaction(SPI_DELAY);
    }

    void init(client spi_master_if self,
                DisplayContext & dc,
                out port * movable dc_port,
                out port reset)
    {
        // Hardware reset
        reset <: 1;
        delay_microseconds(5000);
        reset <: 0;
        delay_microseconds(20000);
        reset <: 1;
        delay_microseconds(150000);

        dc.dc_port = move(dc_port);
        self.setColor(dc, 0x40ff40);
        self.setBackgroundColor(dc, 0x0);
        self.initRegisters(dc);
    }

    void setCols(client spi_master_if self,
                 DisplayContext & dc,
                 int x0, int x1)
    {
        self.sendCommand(dc, ILI9341_CMD_PAGE_ADDRESS_SET);
        self.transfer16(x0);
        self.transfer16(x1);
    }

    void setRows(client spi_master_if self,
                 DisplayContext & dc,
                 int y0, int y1)
    {
        self.sendCommand(dc, ILI9341_CMD_COLUMN_ADDRESS_SET);
        self.transfer16(y0);
        self.transfer16(y1);
    }

    void setXY(client spi_master_if self,
               DisplayContext & dc,
               int x, int y)
    {
        self.setCols(dc, x, x);
        self.setRows(dc, y, y);
    }


    unsigned int setColor(client spi_master_if self,
                          DisplayContext & dc,
                          unsigned int color)
    {
        unsigned int previous = dc.bg_color;
        dc.fg_color = color;
        return previous;
    }

    unsigned int setBackgroundColor(client spi_master_if self,
                                    DisplayContext & dc,
                                    unsigned int color)
    {
        unsigned int previous = dc.bg_color;
        dc.bg_color = color;
        return previous;
    }

    void setFont(client spi_master_if self,
                 DisplayContext & dc,
                 const Font * unsafe font_lookup,
                 const uint8_t * unsafe font_pixels)
    {
        dc.font_lookup = font_lookup;
        dc.font_pixels = font_pixels;

    }

    void drawPixel(client spi_master_if self,
                   DisplayContext & dc,
                   int x, int y)
    {
        if((x<0) || (y<0) || (x >= LCD_WIDTH) || (y >= LCD_HEIGHT)) {
            return;
        }
        self.setXY(dc, x, y);
        self.sendCommand(dc, ILI9341_CMD_MEMORY_WRITE);
        self.transfer16(COLOR24(dc.fg_color));
    }

    void drawLine(client spi_master_if self,
                   DisplayContext & dc,
                   int x0, int y0,
                   int x1, int y1)
    {
        int dx = labs(x1-x0), sx = x0<x1 ? 1 : -1;
        int dy = labs(y1-y0), sy = y0<y1 ? 1 : -1;
        int err = (dx>dy ? dx : -dy)/2, e2;

        self.begin_transaction(DEVICE_ID, SPI_SPEED, SPI_MODE);

        for(;;){
          self.drawPixel(dc, x0,y0);
          if (x0==x1 && y0==y1) break;
          e2 = err;
          if (e2 >-dx) { err -= dy; x0 += sx; }
          if (e2 < dy) { err += dx; y0 += sy; }
        }
        self.end_transaction(SPI_DELAY);
    }

    void drawPolyLine(client spi_master_if self,
                      DisplayContext & dc,
                      Point points[],
                      const int n)
    {
        for (int i=0; i < n-1; i++) {
            Point p1 = points[i];
            Point p2 = points[i+1];
            self.drawLine(dc, p1.x, p1.y, p2.x, p2.y);
        }
    }

    void drawHLine(client spi_master_if self,
                   DisplayContext & dc,
                   int x0, int y,
                   unsigned int length)
    {
        uint16_t color = COLOR24(dc.fg_color);
        int x1 = x0 + length;

        if (x0 >= LCD_WIDTH) {
            return;
        }

        if (x0 < 0) {
            x0 = 0;
        }
        if (x1 >= LCD_WIDTH) {
            x1 = LCD_WIDTH ;
        }

        self.setCols(dc, x0, x1);
        self.setRows(dc, y, y);
        self.sendCommand(dc, ILI9341_CMD_MEMORY_WRITE);

        for (int x=x0; x < x1 ; x++) {
            self.transfer16(color);
        }
    }

    void drawVLine(client spi_master_if self,
                   DisplayContext & dc,
                   int x, int y0,
                   unsigned int length)
    {
        uint16_t color = COLOR24(dc.fg_color);
        int y1 = y0 + length;

        if (y0 >= LCD_HEIGHT) {
            return;
        }

        if (y0 < 0) {
            y0 = 0;
        }
        if (y1 >= LCD_HEIGHT) {
            y1 = LCD_HEIGHT-1;
        }

        self.setCols(dc, x, x);
        self.setRows(dc, y0, y1);
        self.sendCommand(dc, ILI9341_CMD_MEMORY_WRITE);

        for (int y=y0; y<y1; y++) {
            self.transfer16(color);
        }
    }

    void drawFilledRect(client spi_master_if self,
                        DisplayContext & dc,
                        int x, int y,
                        int width, int height)
    {
        uint16_t color = COLOR24(dc.fg_color);
        int n  = width * height;
        int x1 = x + width - 1;
        int y1 = y + height - 1;

        self.begin_transaction(DEVICE_ID, SPI_SPEED, SPI_MODE);
        self.setCols(dc, x, x1);
        self.setRows(dc, y, y1);
        self.sendCommand(dc, ILI9341_CMD_MEMORY_WRITE);

        for(int i=0; i<n; i++) {
            self.transfer16(color);
        }
        self.end_transaction(SPI_DELAY);
    }

    void drawRect(client spi_master_if self,
                  DisplayContext & dc,
                  int x, int y,
                  int width, int height)
    {
        self.begin_transaction(DEVICE_ID, SPI_SPEED, SPI_MODE);
        self.drawHLine(dc, x, y, width);
        self.drawHLine(dc, x, y+height-1, width);

        self.drawVLine(dc, x, y, height);
        self.drawVLine(dc, x+width-1, y, height);
        self.end_transaction(SPI_DELAY);
    }

    void drawCircle(client spi_master_if self,
                    DisplayContext & dc,
                    int cx, int cy,
                    int r)
    {
        int x   = -r;
        int y   = 0;
        int err = 2-2*r;
        int e2;

        self.begin_transaction(DEVICE_ID, SPI_SPEED, SPI_MODE);
        do {
            self.drawPixel(dc, cx-x, cy+y);
            self.drawPixel(dc, cx+x, cy+y);
            self.drawPixel(dc, cx+x, cy-y);
            self.drawPixel(dc, cx-x, cy-y);
            e2 = err;
            if (e2 <= y) {
                err += ++y*2+1;
                if (-x == y && e2 <= x) e2 = 0;
            }
            if (e2 > x) err += ++x*2+1;
        } while (x <= 0);
        self.end_transaction(SPI_DELAY);
    }

    void drawFilledCircle(client spi_master_if self,
                          DisplayContext & dc,
                          int cx, int cy,
                          int r)
    {
        int x = -r;
        int y = 0;
        int err = 2-2*r;
        int e2;

        self.begin_transaction(DEVICE_ID, SPI_SPEED, SPI_MODE);
        do {
            self.drawVLine(dc, cx-x, cy-y, 2*y);
            self.drawVLine(dc, cx+x, cy-y, 2*y);

            e2 = err;
            if (e2 <= y) {
                err += ++y*2+1;
                if (-x == y && e2 <= x) e2 = 0;
            }
            if (e2 > x) err += ++x*2+1;
        } while (x <= 0);
        self.end_transaction(SPI_DELAY);
    }


    void drawLED(client spi_master_if self,
                 DisplayContext & dc,
                 int x, int y,
                 int scale) {


        const int rectangles[] = {0, 0, 1, 4,
                                  0, 3, 3, 1,
                                  2, 0, 1, 7,
                                  0, 0, 3, 1,
                                  0, 0, 1, 7,
                                  0, 6, 3, 1,
                                  2, 0, 1, 7,

                                  } ;
        for (int i=0; i < 12; i+=4) {
            int px = rectangles[i] * scale;
            int py = rectangles[i+1] * scale;
            int pw = rectangles[i+2] * scale;
            int ph = rectangles[i+3] * scale;
            self.drawFilledRect(dc, x + px, y + py, pw, ph);
        }
        x += scale * 4;
        for (int i=12; i < 28; i+=4) {
            int px = rectangles[i] * scale;
            int py = rectangles[i+1] * scale;
            int pw = rectangles[i+2] * scale;
            int ph = rectangles[i+3] * scale;
            self.drawFilledRect(dc, x + px, y + py, pw, ph);
        }
    }

    // copy bitmap picture to screen (16-bit colors)
    void drawBitmap16(client spi_master_if self,
                  DisplayContext & dc,
                  int x, int y,
                  int width, int height,
                  uint16_t buffer[])
    {
        self.setCols(dc, x, x+width-1);
        self.setRows(dc, y, y+height-1);

        self.sendCommand(dc, ILI9341_CMD_MEMORY_WRITE);

        for(int i=0; i < (width * height); i++) {
            self.transfer16(buffer[i]);
        }
    }

    void drawBitmapRGB(client spi_master_if self,
                 DisplayContext & dc,
                 int x, int y,
                 int w, int h,
                 uint8_t buffer[])
    {
        uint8_t r, g, b;

        self.setCols(dc, x, x+w-1);
        self.setRows(dc, y, y+h-1);

        self.sendCommand(dc, ILI9341_CMD_MEMORY_WRITE);

        for(int i=0; i < (w * h * 3); i += 3)  {
            r = buffer[i];
            g = buffer[i+1];
            b = buffer[i+2];
            self.transfer16(COLOR(r, g, b));
        }
    }

    void clear(client spi_master_if self,
               DisplayContext & dc)
    {
        uint16_t color = COLOR24(dc.bg_color);
        int n  = LCD_WIDTH * LCD_HEIGHT;

        self.begin_transaction(DEVICE_ID, SPI_SPEED, SPI_MODE);
        self.setCols(dc, 0, LCD_WIDTH - 1);
        self.setRows(dc, 0, LCD_HEIGHT - 1);
        self.sendCommand(dc, ILI9341_CMD_MEMORY_WRITE);

        for(int i=0; i<n; i++) {
            self.transfer16(color);
        }
        self.end_transaction(SPI_DELAY);
    }


    unsafe void drawText(client spi_master_if self,
                    DisplayContext & dc,
                    const char string[],
                    int px, int py
                    )
    {
        int      index = 0;
        unsigned int  pixel;
        unsigned int  ipixel;
        unsigned int fg_r =  dc.fg_color>>16;
        unsigned int fg_g = (dc.fg_color>>8) & 0xff;
        unsigned int fg_b =  dc.fg_color & 0xff;

        unsigned int bg_r = dc.bg_color>>16;
        unsigned int bg_g = (dc.bg_color>>8) & 0xff;
        unsigned int bg_b = dc.bg_color  & 0xff;
        uint16_t bg = COLOR(bg_r, bg_g, bg_b);
        uint16_t pixel_color ;


        self.begin_transaction(DEVICE_ID, SPI_SPEED, SPI_MODE);
        while (string[index]) {
            char c = string[index];
            const struct font_char font_c = dc.font_lookup[c];
            int left_pad = (font_c.advance+2 - font_c.w) >> 1;
            self.setCols(dc, px, px+font_c.advance+3);
            self.setRows(dc, py, py+FONT_HEIGHT-1);
            self.sendCommand(dc, ILI9341_CMD_MEMORY_WRITE);

            for (int x = 0; x < font_c.advance+2; x++) {
                for (int y = 0; y < FONT_HEIGHT; y++) {
                    int y_index = y - font_c.top;
                    if (x<left_pad || x>=(font_c.w+left_pad) || y_index < 0 || y_index>=font_c.h) {
                        pixel_color = bg;
                    } else {
                        // alpha blend foreground and background
                        pixel = dc.font_pixels[font_c.offset + x-left_pad + y_index * font_c.w];
                        ipixel = 255 - pixel;

                        pixel_color = COLOR((pixel*fg_r + ipixel*bg_r)/255,
                                            (pixel*fg_g + ipixel*bg_g)/255,
                                            (pixel*fg_b + ipixel*bg_b)/255);
                    }
                    self.transfer16(pixel_color);
                }
            }
            px += font_c.advance+2;
            index++;
        }
        self.end_transaction(SPI_DELAY);
    }
}
