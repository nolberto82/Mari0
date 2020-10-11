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
        private string graphicfilter;
        public List<Spritebatch> batch;
        private RasterizerState rasterState;
        public Rectangle scissorRect;
        public Texture2D recttexture;

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
            lua.RegisterFunction("love.graphics.setDefaultFilter", this, typeof(Graphics).GetMethod("setDefaultFilter"));
            lua.RegisterFunction("love.graphics.newSpriteBatch", this, typeof(Graphics).GetMethod("newSpriteBatch"));
            lua.RegisterFunction("love.graphics.setScissor", this, typeof(Graphics).GetMethod("setScissor"));
            lua.RegisterFunction("love.graphics.rectangle", this, typeof(Graphics).GetMethod("rectangle"));

            rasterState = new RasterizerState();
            rasterState.MultiSampleAntiAlias = true;
            rasterState.ScissorTestEnable = true;
            rasterState.FillMode = FillMode.Solid;
            rasterState.CullMode = CullMode.CullCounterClockwiseFace;
            rasterState.DepthBias = 0;
            rasterState.SlopeScaleDepthBias = 0;

            setScissor();

            recttexture = new Texture2D(game.GraphicsDevice, 1, 1, false, SurfaceFormat.Color);
            recttexture.SetData<Color>(new Color[] { Color.White });
        }

        void translatecoords(ref float x, ref float y)
        {
            x += transX;
            y += transY;
        }

        public void draw(params object[] args)
        {
            float depth = 1f;

            sb.Begin(SpriteSortMode.FrontToBack, BlendState.AlphaBlend, getDefaultFilter(), null, rasterState);

            game.GraphicsDevice.ScissorRectangle = scissorRect;

            if (args[0] is Spritebatch)
            {
                Spritebatch sbatch = (Spritebatch)args[0];
                float xscroll = Convert.ToSingle(args[1]);
                foreach (var b in sbatch.batch)
                {
                    var quad = b.quad;
                    var x = b.x + xscroll;
                    var y = b.y;
                    var r = b.r;
                    var sx = b.sx;
                    var sy = b.sy;
                    var ox = b.ox;
                    var oy = b.oy;

                    SpriteEffects flip = sx < 0 ? SpriteEffects.FlipHorizontally : SpriteEffects.None;

                    if (quad != null)
                    {
                        Rectangle srcrect = new Rectangle(quad.x, quad.y, quad.w, quad.h);
                        sb.Draw(sbatch.image.texture, new Vector2(x, y), srcrect, currentcolor, r, new Vector2(ox, oy), new Vector2(Math.Abs(sx), sy), flip, depth);
                    }
                }
            }
            else
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

                translatecoords(ref x, ref y);

                //x += (ox * Math.Abs(sx));
                //y += (oy * Math.Abs(sy));

                r *= (float)(180 / Math.PI);

                SpriteEffects flip = sx < 0 ? SpriteEffects.FlipHorizontally : SpriteEffects.None;

                if (quad != null)
                {
                    Rectangle srcrect = new Rectangle(quad.x, quad.y, quad.w, quad.h);
                    sb.Draw(img.texture, new Vector2(x, y), srcrect, currentcolor, r, new Vector2(ox, oy), new Vector2(Math.Abs(sx), sy), flip, depth);
                }
                else
                {
                    sb.Draw(img.texture, new Vector2(x, y), null, currentcolor, r, new Vector2(ox, oy), new Vector2(Math.Abs(sx), sy), flip, depth);
                }
            }

            sb.End();
        }

        public Spritebatch newSpriteBatch(params object[] args)
        {
            var img = (Image)args[0];
            List<Spritebatch> obj_sb = new List<Spritebatch>();
            obj_sb.Add(new Spritebatch(img));

            return obj_sb[0];
        }

        public void setScissor(params int[] args)
        {
            if (args.Length == 0)
            {
                scissorRect = new Rectangle(0, 0, game.Window.ClientBounds.Width, game.Window.ClientBounds.Height);
                return;
            }

            var x = args[0];
            var y = args[1];
            var w = args[2];
            var h = args[3];

            scissorRect = new Rectangle(x, y, w, h);
        }

        public void setDefaultFilter(params string[] args)
        {
            graphicfilter = args[0];
        }

        public SamplerState getDefaultFilter()
        {
            if (graphicfilter == "nearest")
            {
                return SamplerState.PointClamp;
            }

            return null;
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

        public void rectangle(params object[] args)
        {
            var mode = args[0].ToString();
            var x = Convert.ToInt32(args[1]);
            var y = Convert.ToInt32(args[2]);
            var w = Convert.ToInt32(args[3]);
            var h = Convert.ToInt32(args[4]);

            sb.Begin(SpriteSortMode.Deferred, BlendState.AlphaBlend, getDefaultFilter(), null, rasterState);

            if (mode == "fill")
            {
                sb.Draw(recttexture, new Rectangle(x, y, w, h), currentcolor);
            }
            else
            {

            }

            sb.End();
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
            float a = args.Length == 4 ? args[3] : 1f;

            currentcolor = new Color(r, g, b, a);
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
