#include <cstdlib>
#include <filesystem>
#include <fmt/core.h>
#include <iostream>
#include <string>
#include <sys/utsname.h>
#include <unistd.h>

namespace fs = std::filesystem;

static std::string env_or_empty(const char* name) {
    const char* value = std::getenv(name);
    return value ? value : "<not set>";
}

int main() {
    char hostname[256]{};
    gethostname(hostname, sizeof(hostname) - 1);

    utsname info{};
    uname(&info);

    const bool docker_marker = fs::exists("/.dockerenv");
    const auto source_path = fs::absolute(__FILE__).lexically_normal();

    fmt::print("=== Dev Container Check ===\n");
    std::cout << "docker_container : " << (docker_marker ? "yes" : "no") << '\n';
    std::cout << "hostname         : " << hostname << '\n';
    std::cout << "cwd              : " << fs::current_path() << '\n';
    std::cout << "source           : " << source_path << '\n';
    std::cout << "system           : " << info.sysname << ' ' << info.release << ' ' << info.machine << '\n';
    std::cout << "compiler         : " << __VERSION__ << '\n';
    std::cout << "c++_standard     : " << __cplusplus << '\n';
    std::cout << "VCPKG_ROOT       : " << env_or_empty("VCPKG_ROOT") << '\n';
    std::cout << "CMAKE_TOOLCHAIN  : " << env_or_empty("CMAKE_TOOLCHAIN_FILE") << '\n';

    if (!docker_marker) {
        std::cerr << "\nERROR: this program is NOT running inside a Docker container.\n";
        return 1;
    }

    std::cout << "\nOK: running inside a Docker container.\n";
    return 0;
}
