/*
 * lcd_interface.h
 *
 *  Created on: Mar 28, 2016
 *      Author: ah6
 */

#ifndef LCD_INTERFACE_H_
#define LCD_INTERFACE_H_

#include "font.h"

typedef struct {
    out port  * movable dc_port;
    unsigned int fg_color;
    unsigned int bg_color;
    const Font * unsafe font_lookup;
    const uint8_t * unsafe font_pixels;

} DisplayContext;


extends client interface spi_master_if  : {
    void init(client spi_master_if self,
              DisplayContext & dc,
              out port * movable dc_port);

    void initRegisters(client spi_master_if self,
                       DisplayContext & dc);


    unsigned int setColor(client spi_master_if self,
                               DisplayContext & dc,
                               unsigned int color) ;

    unsigned int setBackgroundColor(client spi_master_if self,
                                    DisplayContext & dc,
                                    unsigned int color);

    void setFont(client spi_master_if self,
                 DisplayContext & dc,
                 const Font * unsafe font_lookup,
                 const uint8_t * unsafe font_pixels);

    void drawLED(client spi_master_if self,
                 DisplayContext & dc,
                 int x, int y,
                 int scale);

    void drawLine(client spi_master_if self,
                   DisplayContext & dc,
                   int x1, int y1,
                   int x2, int y2);

    void drawFilledRect(client spi_master_if self,
                        DisplayContext & dc,
                        int x, int y,
                        int w, int h);

    void drawRect(client spi_master_if self,
                  DisplayContext & dc,
                  int x, int y,
                  int width, int height);

    void drawCircle(client spi_master_if self,
                    DisplayContext & dc,
                    int cx, int cy,
                    int r);

    void drawFilledCircle(client spi_master_if self,
                          DisplayContext & dc,
                          int cx, int cy,
                          int r);

    unsafe void drawText(client spi_master_if self,
                    DisplayContext & dc,
                    const char string[],
                    int px, int py
                    );

    void clear(client spi_master_if self,
               DisplayContext & dc);

}
#endif /* LCD_INTERFACE_H_ */
