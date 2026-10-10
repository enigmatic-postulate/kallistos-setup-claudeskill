// Minimal KallistiOS + sh4zam smoke test (C++ API).
#include <cstdio>
#include <kos.h>
#include <sh4zam/shz_sh4zam.hpp>

int main(int, char*[]) {
    // Show printf output on screen (not just the dcload/serial console).
    dbgio_dev_select("fb");

    shz::vec4 v1(2.0f, 3.0f, 4.0f, 1.0f);
    shz::vec4 v2 = shz::vec4(v1 * shz::sinf(shz::pi_f * 0.5f)).direction();
    shz::mat4x4 m {};

    shz::xmtrx::init_diagonal(1.0f, 1.0f, 1.0f, 1.0f);
    shz::xmtrx::apply_rotation_x(shz::pi_f * 0.25f);
    shz::xmtrx::apply_translation(v1.x, v1.y, v1.z);
    shz::xmtrx::store(&m);

    shz::vec4 v3 = shz::xmtrx::transform(v2);

    std::printf("sh4zam hello (C++)\n");
    std::printf("  dot(v1, v2) = %.3f\n", double(v1.dot(v2)));
    std::printf("  XMTRX * v2  = (%.3f, %.3f, %.3f, %.3f)\n",
                double(v3.x), double(v3.y), double(v3.z), double(v3.w));
    // Keep the output visible until Start is pressed.
    std::printf("\nPress Start to exit.\n");
    for(;;) {
        maple_device_t *cont = maple_enum_type(0, MAPLE_FUNC_CONTROLLER);
        auto *st = cont ? static_cast<cont_state_t *>(maple_dev_status(cont)) : nullptr;
        if(st && (st->buttons & CONT_START))
            break;
        thd_sleep(50);
    }

    return 0;
}
