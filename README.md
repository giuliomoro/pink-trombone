# pink-trombone

The original source code is from http://dood.al/pinktrombone/

Port for Bela: written in C++, plugged into the simple Bela API.

## Compile and run

### Requirements:

You need the `dev-libbela` branch of the Bela repo in `/root/Bela`.
If the board is connected to the internet, this should get you sorted, otherwise use your imagination to get the correct repos and branches on the board.

```
git clone git@github.com:giuliomoro/pink-trombone.git /root/pink-trombone 
cd /root/pink-trombone
git checkout bela

git clone git@github.com:BelaPlatform/Bela.git /root/Bela
cd /root/Bela
git checkout dev-libbela
# Apply a patch that will give you some more CPU
patch core/PRU.cpp < /root/pink-trombone/PRU.cpp.patch
make coreclean
# Build libbela in /root/Bela/lib
make lib
# Tell the dynamic loader about libbela
ldconfig /root/Bela/lib
```

### Compile pink-trombone

```
cd /root/pink-trombone
make
```

### Run !

```
./trombone
```

## The code

This is not a good example of C++ code.

I ported the Javascript to C++ aiming at keeping the changes to a minimum and *without* understanding the code.
Once this was done and the thing was basically running, I had to understand more about the code in order to be able to use it. See if you can make any sense of the comments at the top of `trombone.cpp`.

The most often applied change was `s/this\./this->/g`.
I added `Math` namespace which implements the required `Math` functions. Replacing these with the equivalents from `math_neon` could improve the performance perhaps?
All the methods and properties are `public` and I tend to use references where possible to stick with the original Javascript `.` notations.
Final result is pretty crappy looking but it works.

I keep everything in `trombone.cpp` because I could not be bothered factoring out the `class` declarations (and also because some methods are called multiple times per sample, so they benefit from inlining), though this makes the compile a bit slower than I'd wish for.

The Cortex-A8 on Bela does not really like `double` operations, so I also `typedef float sample_t` and casted all the relevant numeric constants to `(sample_t)`.
This could have been done by using the `-fsingle-precision-constant` compiler options, but it is only supported by `gcc`, while I used `clang` because it gives better performance.


## Use

As I understand it, you have these controls on the model:

* the `diameter` of the `Tract`. This is represented as an array of 44 values ("`index`"). Typical values are between 0 and 2.
* the openness of the `velum` (`0.01` for closed, `0.4` for open)
* the pitch of the `Glottis` (the x-axis in the "voicebox" in the GUI)
* the `tenseness` of the `Glottis` (the y-axis in the "voicebox" in the GUI). This also affects the `loudness`.
* transients are generated when the diameter at one `index` used to be 0 and becomes > 0, basically when an obstruction of the tract is removed. This happens automatically as you change the `diameter` values, but you could also add them manually with `addTransient()`
* the amount of `turbulence` due to reduced `diameter`

Most of these (except the `turbulence`) can be safely updated manually (see example in the `render` function).

Alternatively, you can fake touches, this includes generic touches (anywhere in the Tract) and `tongueTouch`: the one touch that controls the position of the tongue (the circle in the GUI).
After you add a touch you need to call `TractUI->handleTouches()` for it to be handled.
I did not implement `Glottis::handleTouches()`, it is easier to just set the `UItenseness` and `UIfrequency` directly.

The trick with touches at the moment is that it is not easy to place them in the righ place. I ended up printing touch coordinates from the GUI and then hard-code them in the code.
The good thing about touches is that they take care of the `turbulence` parameter, which is not achieved otherwise (I mean I tried to implement it (see "attempt to compensate for touch.fricative_intensity when setting" in the code), but it's too CPU intensive).

More stuff is in the comments at the top of the file, everything is in the code.
