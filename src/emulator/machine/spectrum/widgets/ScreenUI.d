module emulator.machine.spectrum.widgets.ScreenUI;

import emulator.machine.spectrum.all;
import vulkan.all;

/**
 *  Display Spectrum screen
 *      Pixel data:
 *          - 32x24 bytes
 *          - 256x192 pixels
 *
 *      Attribute data:
 *          - 32x24 bytes
 *
 *  FLASH, BRIGHT, PAPER(3 bits), INK(3 bits)
 *
 * | 4000 | 57ff | Screen Pixel Memory     | 6144 (0x1800) bytes
 * | 5800 | 5aff | Screen attribute Memory | 768 (0x300) bytes
 */
final class ScreenUI {
private:
    enum BORDER       = 20;
    enum IMAGE_WIDTH  = 256*2 + BORDER*2;
    enum IMAGE_HEIGHT = 192*2 + BORDER*2;
    enum Attrib {
        INK     = 0b111,
        PAPER   = 0b111<<3,
        BRIGHT  = 1<<6,
        FLASH   = 1<<7
    }
    immutable RGBAb[] COLOURS = [
        RGBAb(0,0,0,0xff),           // 0 Black
        RGBAb(0,0,0xee,0xff),        // 1 Blue
        RGBAb(0xee,0,0,0xff),        // 2 Red
        RGBAb(0xee,0,0xee,0xff),     // 3 Magenta
        RGBAb(0,0xee,0,0xff),        // 4 Green
        RGBAb(0,0xee,0xee,0xff),     // 5 Cyan
        RGBAb(0xee,0xee,0,0xff),     // 6 Yellow
        RGBAb(0xee,0xee,0xee,0xff),  // 7 White

        RGBAb(0,0,0,0xff),           // 0 Bright Black
        RGBAb(0,0,0xff,0xff),        // 1 Bright Blue
        RGBAb(0xff,0,0,0xff),        // 2 Bright Red
        RGBAb(0xff,0,0xff,0xff),     // 3 Bright Magenta
        RGBAb(0,0xff,0,0xff),        // 4 Bright Green
        RGBAb(0,0xff,0xff,0xff),     // 5 Bright Cyan
        RGBAb(0xff,0xff,0,0xff),     // 6 Bright Yellow
        RGBAb(0xff,0xff,0xff,0xff),  // 7 Bright White
    ];
    @Borrowed VulkanContext context;
    @Borrowed Spectrum spectrum;
    @Borrowed Memory memory;
    @Borrowed Z80Ports ports;
    UpdateableImage!(VFormat.R8G8B8A8_UNORM) image;
    Quads quads;
    VkSampler sampler;
    Camera2D camera;

    int borderColour = -1;
public:
    this(VulkanContext context, Spectrum spectrum) {
        this.context = context;
        this.spectrum = spectrum;
        this.memory = spectrum.getMemory();
        this.ports = spectrum.getPorts();

        this.camera = Camera2D.forVulkan(context.vk.windowSize());
        this.sampler = context.device.createSampler(samplerCreateInfo());

        this.image = new UpdateableImage!(VFormat.R8G8B8A8_UNORM)(
            context,
            IMAGE_WIDTH,
            IMAGE_HEIGHT,
            VImageUsage.SAMPLED,
            VImageLayout.SHADER_READ_ONLY_OPTIMAL
        );
        this.image
            .image.createView(VFormat.R8G8B8A8_UNORM, VImageViewType._2D, VImageAspect.COLOR);
        this.image.clear(RGBAb(0xee, 0xee, 0xee, 0xff));

        this.quads = new Quads(context, image.getImageMeta(), sampler, 1);
        quads.camera(camera)
             .setSize(float2(IMAGE_WIDTH, IMAGE_HEIGHT))
             .add(float2(10,30));
    }
    void destroy() {
        if(quads) quads.destroy();
        if(image) image.destroy();
        if(sampler) context.device.destroySampler(sampler);
    }
    void update(Frame frame) {
        updateImage(frame);
        quads.beforeRenderPass(frame);
    }
    void render(Frame frame) {
        quads.insideRenderPass(frame);
    }
private:
    RGBAb getPixelColour(double seconds, bool pixel, ubyte attrib) {
        bool flash    = (attrib & Attrib.FLASH) != 0;
        bool bright   = (attrib & Attrib.BRIGHT) != 0;

        if(flash) {
            bool flipflop = ((seconds*2.0).as!uint & 1) == 1;
            if(flipflop) {
                // Swap paper and ink
                pixel = !pixel;
            }
        }

        uint col = pixel
            ? attrib & Attrib.INK               // ink
            : (attrib & Attrib.PAPER) >>> 3;    // paper

        col |= (bright ? 1<<3 : 0);             // bright

        return COLOURS[col];
    }
    void writeBorder(Frame frame) {
        ubyte value = ports.data[0xfe];

        if(value == borderColour) {
            // The border colour hasn't changed so no need to re-write it
            return;
        }

        borderColour = value;
        RGBAb colour = COLOURS[borderColour];

        RGBAb* ptr = image.map();

        // Top
        ptr[0..IMAGE_WIDTH*BORDER] = colour;

        // Left & right
        foreach(y; BORDER..BORDER+192*2) {
            auto left  = ptr + IMAGE_WIDTH*y;
            auto right = left + BORDER + 256*2;

            foreach(x; 0..BORDER) {
                left[x] = colour;
                right[x] = colour;
            }
            left  += IMAGE_WIDTH;
            right += IMAGE_WIDTH;
        }

        // Bottom
        ptr[IMAGE_WIDTH*(BORDER+192*2)..IMAGE_WIDTH*IMAGE_HEIGHT] = colour;
    }
    void writeScreen(Frame frame) {
        RGBAb* destPtr      = image.map() + (BORDER*IMAGE_WIDTH)+BORDER; // adjust for border
        ubyte* srcPixelPtr  = &memory.data[0x4000];   // screen pixel data
        ubyte* srcAttribPtr = &memory.data[0x5800];   // screen attribute data

        void _pixel(uint dest, ubyte attribute) {
            ubyte pixels = *srcPixelPtr++;

            foreach(i; 0..8) {
                auto col = getPixelColour(frame.seconds, (pixels&0x80)!=0, attribute);
                auto p   = destPtr + dest + i + i;

                p[0] = col;
                p[1] = col;
                p[IMAGE_WIDTH]   = col;
                p[IMAGE_WIDTH+1] = col;

                pixels <<= 1;
            }
        }

        // 3 blocks
        foreach(j; 0..3) {

            // 64 rows
            foreach(row; 0..8*8) {

                // row of 32 bytes (256 pixels)
                foreach(x; 0..32) {

                    ubyte attribute = srcAttribPtr[x + (row&7)*32];

                    auto y = (row >>> 3) + (row & 7)*8;

                    auto d = x*8*2 + y*IMAGE_WIDTH*2;

                    _pixel(d, attribute);
                }
            }
            // The next block of attributes starts 8 rows down
            srcAttribPtr += 32*8;

            destPtr += IMAGE_WIDTH*64*2;
        }
    }
    void updateImage(Frame frame) {

        writeScreen(frame);
        writeBorder(frame);

        image.setDirty();
        image.upload(frame.resource.adhocCB);
    }
}
