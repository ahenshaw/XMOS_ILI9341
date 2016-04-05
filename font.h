/*
 * font.h
 *
 *  Created on: Apr 4, 2016
 *      Author: ah6
 */


#ifndef FONT_H_
#define FONT_H_

typedef struct font_char {
    int offset;
    int w;
    int h;
    int left;
    int top;
    int advance;
} Font;

#endif /* FONT_H_ */
