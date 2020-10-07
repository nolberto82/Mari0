using Microsoft.Xna.Framework.Graphics;
using System;
using System.Collections.Generic;

namespace Love2D
{
    public class Spritebatch
    {
        public List<Spritebatch> batch;
        public Image image;
        public Quad quad;
        public float x;
        public float y;
        public float r;
        public float sx;
        public float sy;
        public float ox;
        public float oy;

        public Spritebatch(Image img)
        {
            batch = new List<Spritebatch>();
            image = img;
        }

        public Spritebatch(params object[] args)
        {
            quad = (Quad)args[0];
            x = Convert.ToSingle(args[1]);
            y = Convert.ToSingle(args[2]);
            r = Convert.ToSingle(args[3]);
            sx = Convert.ToSingle(args[4]);
            sy = Convert.ToSingle(args[5]);
            ox = Convert.ToSingle(args.Length > 7 ? args[6] : 0);
            oy = Convert.ToSingle(args.Length > 7 ? args[7] : 0);
        }

        public void add(params object[] args)
        {
            batch.Add(new Spritebatch(args));
        }

        public void clear()
        {
            batch.Clear();
        }
    }
}
