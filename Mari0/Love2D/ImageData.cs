using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Love2D
{
    public class ImageData
    {
        Color[] data;
        Color[,] pixels;

        public ImageData(string filepath, GraphicsDevice gd)
        {
            using (FileStream filestream = new FileStream(filepath, FileMode.Open))
            {
                Texture2D texture = Texture2D.FromStream(gd, filestream);
                data = new Color[texture.Width * texture.Height];
                pixels = new Color[texture.Width, texture.Height];
                texture.GetData<Color>(data);

                for (int y = 0; y < texture.Height; y++)
                {
                    for (int x = 0; x < texture.Width; x++)
                    {
                        pixels[x, y] = data[x + y * texture.Width];
                    }
                }
            }
        }

        public void getPixel(out float r, out float g, out float b, out float a, params int[] args)
        {
            var x = args[0];
            var y = args[1];

            r = pixels[x, y].R / 255f;
            g = pixels[x, y].G / 255f;
            b = pixels[x, y].B / 255f;
            a = pixels[x, y].A / 255f;
        }
    }
}
