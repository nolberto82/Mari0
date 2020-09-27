using System;
using System.Collections.Generic;
using System.Text;

namespace Love2D
{
    public class Quad
    {
        public int x;
        public int y;
        public int w;
        public int h;
        public int sw;
        public int sh;
        public bool collision;
        public bool invisible;
        public bool breakable;
        public bool coinblock;
        public bool coin;

        public Quad(int _x, int _y, int _width, int _height, int _sw, int _sh)
        {
            x = _x;
            y = _y;
            w = _width;
            h = _height;
            sw = _sw;
            sh = _sh;
        }
    }
}
