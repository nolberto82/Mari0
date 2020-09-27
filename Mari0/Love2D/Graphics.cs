using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.Graphics;
using NLua;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Love2D
{
    public class Graphics
    {
        private Lua lua;
        private Game game;
        private SpriteBatch sb;
        private Color currentcolor;
        private Color backgroundcolor;
        private float transX;
        private float transY;

        public Graphics(Lua l, Game g)
        {
            lua = l;
            game = g;
            sb = (SpriteBatch)game.Services.GetService(typeof(SpriteBatch));

            new Image(lua, game);

            lua.NewTable("love.graphics");

            lua.RegisterFunction("love.graphics.newImage", this, typeof(Graphics).GetMethod("newImage"));
            lua.RegisterFunction("love.graphics.newQuad", this, typeof(Graphics).GetMethod("newQuad"));
            lua.RegisterFunction("love.graphics.getWidth", this, typeof(Graphics).GetMethod("getWidth"));
            lua.RegisterFunction("love.graphics.getHeight", this, typeof(Graphics).GetMethod("getHeight"));
            lua.RegisterFunction("love.graphics.clear", this, typeof(Graphics).GetMethod("clear"));
            lua.RegisterFunction("love.graphics.setColor", this, typeof(Graphics).GetMethod("setColor"));
            lua.RegisterFunction("love.graphics.setBackgroundColor", this, typeof(Graphics).GetMethod("setBackgroundColor"));
            lua.RegisterFunction("love.graphics.getBackgroundColor", this, typeof(Graphics).GetMethod("getBackgroundColor"));
            lua.RegisterFunction("love.graphics.draw", this, typeof(Graphics).GetMethod("draw"));
            lua.RegisterFunction("love.graphics.translate", this, typeof(Graphics).GetMethod("translate"));
        }

        void translatecoords(ref float x, ref float y)
        {
            x += transX;
            y += transY;
        }

        public void draw(params object[] args)
        {
            Image img = (Image)args[0];
            Quad quad = null;

            var start = 1;
            if (args[1] is Quad)
            {
                quad = (Quad)args[1];
                start = 2;
            }

            var x = Convert.ToSingle(args[start + 0]);
            var y = Convert.ToSingle(args[start + 1]);
            var r = Convert.ToSingle(args[start + 2]);
            var sx = Convert.ToSingle(args[start + 3]);
            var sy = Convert.ToSingle(args[start + 4]);
            var ox = Convert.ToSingle(args.Length > 7 ? args[start + 5] : 0);
            var oy = Convert.ToSingle(args.Length > 7 ? args[start + 6] : 0);
            var type = args.Length > 8 && start == 1 ? args[start + 7] : "";

            SpriteEffects flip = sx < 0 ? SpriteEffects.FlipHorizontally : SpriteEffects.None;

            if (type.ToString() == "bighat")
            {
                if (sx < 0)
                {

                }
            }

            if (quad != null)
            {
                Rectangle srcrect = new Rectangle(quad.x, quad.y, quad.w, quad.h);
                sb.Draw(img.texture, new Vector2(x, y), srcrect, currentcolor, r, new Vector2(ox, oy), new Vector2(Math.Abs(sx), sy), flip, 1f);
            }
            else
            {
                sb.Draw(img.texture, new Vector2(x, y), null, currentcolor, r, new Vector2(ox, oy), new Vector2(Math.Abs(sx), sy), flip, 1f);
            }
        }

        public Image newImage(params string[] args)
        {
            string path = args[0];

            if (!File.Exists(path))
                return null;

            List<Image> obj_img = new List<Image>();
            obj_img.Add(new Image(path, game.GraphicsDevice));

            return obj_img[0];
        }

        public Quad newQuad(params int[] args)
        {
            var x = args[0];
            var y = args[1];
            var w = args[2];
            var h = args[3];
            var sw = args[4];
            var sh = args[5];

            List<Quad> obj_quad = new List<Quad>();
            obj_quad.Add(new Quad(x, y, w, h, sw, sh));

            return obj_quad[0];
        }

        public void clear()
        {
            game.GraphicsDevice.Clear(new Color(0, 0, 0));
        }

        public void setColor(params float[] args)
        {
            float r = args[0];
            float g = args[1];
            float b = args[2];

            currentcolor = new Color(r, g, b);
        }

        public void setBackgroundColor(params float[] args)
        {
            float r = args[0];
            float g = args[1];
            float b = args[2];

            backgroundcolor = new Color(r, g, b);

            game.GraphicsDevice.Clear(backgroundcolor);
        }

        public Color getBackgroundColor()
        {
            return backgroundcolor;
        }

        public void translate(params float[] args)
        {
            var dx = args[0];
            var dy = args[1];

            transX += dx;
            transY += dy;
        }

        public int getWidth()
        {
            return game.GraphicsDevice.PresentationParameters.BackBufferWidth;
        }

        public int getHeight()
        {
            return game.GraphicsDevice.PresentationParameters.BackBufferHeight;
        }
    }
}
