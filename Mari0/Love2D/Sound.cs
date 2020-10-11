using Microsoft.Xna.Framework.Audio;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Love2D
{
    public class Sound
    {
        public SoundEffectInstance sound;

        public Sound(string path)
        {
            using (FileStream filestream = new FileStream(path, FileMode.Open, FileAccess.Read))
            {
                sound = SoundEffect.FromStream(filestream).CreateInstance();
            }
        }

        public void setVolume(params float[] args)
        {
            float value = args[0];
            value = value > 1f ? 1f : value < 0 ? 0f : value;

            sound.Volume = value;
        }

        public void play()
        {
            sound.Play();
        }

        public void stop()
        {
            sound.Stop();
        }

        public void setLooping(params bool[] args)
        {
            bool isLoop = args[0];

            sound.IsLooped = isLoop;
        }
    }
}
