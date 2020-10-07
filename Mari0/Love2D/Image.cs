using NLua;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Love2D
{
    public class Image
    {
        public Texture2D texture;
        private Lua lua;
        private Game game;

        public Image(Lua l, Game g)
        {
            lua = l;
            game = g;

            lua.NewTable("love.image");
            lua.RegisterFunction("love.image.newImageData", this, typeof(Image).GetMethod("newImageData"));
        }

        public Image(string path, GraphicsDevice gd)
        {
            using (FileStream filestream = new FileStream(path, FileMode.Open, FileAccess.Read))
            {
                texture = Texture2D.FromStream(gd, filestream);
            }
        }

        public ImageData newImageData(params string[] args)
        {
            var path = args[0];

            if (!File.Exists(path))
                return null;

            List<ImageData> obj_imgdata = new List<ImageData>();
            obj_imgdata.Add(new ImageData(path, game.GraphicsDevice));

            return obj_imgdata[0];
        }

        public int getWidth()
        {
            return texture.Width;
        }

        public int getHeight()
        {
            return texture.Height;
        }

        public void setFilter(params string[] args)
        {
            //texture.GraphicsDevice.SamplerStates[0].Filter = TextureFilter.
        }
    }
}
