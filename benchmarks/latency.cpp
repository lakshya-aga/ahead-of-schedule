#include <chrono>
#include <iostream>
#include <thread>

int main()
{
    using clock = std::chrono::steady_clock;

    for (int i = 0; i < 10; ++i) {
        auto expected = clock::now() + std::chrono::milliseconds(10);

        std::this_thread::sleep_until(expected);

        auto actual = clock::now();

        auto latency =
            std::chrono::duration_cast<std::chrono::microseconds>(
                actual - expected
            );

        std::cout << latency.count() << " us\n";
    }
}
