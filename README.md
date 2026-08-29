# STM32F103 CLion Template

一个基于 **江科大（江协科技）STM32F10x 标准库模板** 的 **CLion / CMake 工程模板**。

可直接下载使用，在 CLion 中完成编译、烧录与在线调试，也支持纯命令行构建。

---

## 功能特性

- 基于江科大 STM32F10x 标准库模板（SPL），保留其经典目录结构，可直接在其基础上添加外设
- 最小可构建固件：CLion 一键编译 / 烧录 / 调试
- GNU 格式启动文件（`startup_stm32f10x_md.s`），矢量表完整，弱符号中断处理可在 `stm32f10x_it.c` 中覆盖
- CMSIS 5 内核层 + SPL 标准外设库
- 自带 OpenOCD 烧录配置（`stm32f103c8_blue_pill.cfg`，适配 ST-Link + SWD）

---

## 下载仓库

**方式一：git clone**

```bash
git clone https://github.com/fangzhang299/stm32f103-clion-template.git
```

**方式二：下载 ZIP**

打开仓库页面 → 点击右上角绿色 **Code** 按钮 → **Download ZIP** → 解压到本地。

---

## 快速开始

1. **打开项目**：用 CLion 打开仓库文件夹（包含 `CMakeLists.txt` 的那一层）
2. **配置工具链**（重要，否则会用 MinGW 编译报错）：
  - 直接在 弹出的CMake 工具窗口中切换到 `CMakePresets.json` 里的 **Debug 预设**（必须取消勾选默认的Debug，使能Debug 预设）

-<img width="617" height="524" alt="屏幕截图 2026-08-26 155629" src="https://github.com/user-attachments/assets/156aaf3c-4987-4b84-916c-64e3bb5231c0" />

  - **或者：**
  - 菜单 **Settings → Build, Execution, Deployment → CMake**
  - 选中 **Debug** profile，在 **CMake options** 栏填写：
     ```
     -DCMAKE_TOOLCHAIN_FILE=<项目路径>/cmake/gcc-arm-none-eabi.cmake
     ```
   
3. **重新加载**：**Tools → CMake → Reload CMake Project**
4. **构建**：点击运行/构建按钮，生成 `build/Clion_STL_model.elf`

-<img width="1037" height="727" alt="屏幕截图 2026-08-26 155700" src="https://github.com/user-attachments/assets/152c9651-8c37-486c-8773-1b1d9aad005c" />

5. **烧录**：接好 ST-Link（SWDIO→PA13、SWCLK→PA14、GND、3.3V），运行 OpenOCD 配置或执行：
   ```bash
   openocd -f stm32f103c8_blue_pill.cfg \
           -c "program build/Clion_STL_model.elf verify reset exit"
   ```
   看到 `Verified OK` 即烧录成功。

> 也可以用 STM32CubeProgrammer 烧录：
> ```bash
> STM32_Programmer_CLI -c port=SWD -w build/Clion_STL_model.elf -v -rst
> ```

---

## OpenOCD 配置（CLion 一键烧录 / 调试）

本模板自带 OpenOCD 配置文件 **`stm32f103c8_blue_pill.cfg`**，在 CLion 中配置一次即可一键烧录和调试。

### 1. 配置文件说明

`stm32f103c8_blue_pill.cfg` 是自包含配置，做了以下事情：

```tcl
source [find interface/stlink.cfg]      # ① 加载 ST-Link 接口
transport select swd                    # ② 选择 SWD 传输方式
source [find target/stm32f1x.cfg]       # ③ 加载 STM32F103 目标芯片
```

- 如果用的是 **J-Link / DAP-Link**，把 `interface/stlink.cfg` 换成 `interface/jlink.cfg` 或 `interface/cmsis-dap.cfg` 即可
- 如果烧录时报 `timed out while waiting for target halted`，可把 `adapter speed 500` 再调低（如 `100`）

### 2. 在 CLion 中新建 OpenOCD 运行配置

1. 菜单 **Run → Edit Configurations…**

-<img width="1031" height="456" alt="屏幕截图 2026-08-26 155723" src="https://github.com/user-attachments/assets/721e3a38-6190-40c6-8375-7e232af5d93e" />                                       
2. 点左上角 **+** → 选择 **OpenOCD Download & Run**

-<img width="599" height="517" alt="屏幕截图 2026-08-26 155740" src="https://github.com/user-attachments/assets/afc1783d-1ad5-463e-a2a7-e484adaa2edc" />

3. 填写：
   - **Executable**：`build/Clion_STL_model.elf`
   - **Config options**：`-f stm32f103c8_blue_pill.cfg`

-<img width="897" height="533" alt="屏幕截图 2026-08-26 155825" src="https://github.com/user-attachments/assets/8525d11b-dabe-4e7d-9c1f-aeda64044c93" />

4. 勾选 **Download before run**（烧录后自动运行）
5. 点 **运行 ▶** 烧录到板子；点 **调试 🐞** 进入在线调试（断点、单步、查看变量）

-<img width="1037" height="725" alt="屏幕截图 2026-08-26 155840" src="https://github.com/user-attachments/assets/a0102c42-0510-4325-8ecd-fcec74a01e45" />

> 若 CLion 里没有 "OpenOCD Download & Run" 类型，选择 **Embedded GDB Server**，在 Interface 中选 OpenOCD，并填入相同的 Config options。

---

## 命令行方式（不使用 CLion）

```bash
# 构建
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_TOOLCHAIN_FILE=cmake/gcc-arm-none-eabi.cmake
cmake --build build

# 烧录
openocd -f stm32f103c8_blue_pill.cfg \
        -c "program build/Clion_STL_model.elf verify reset exit"
```

---

## 目录结构

```
.
├── User/                # 用户代码：main.c、stm32f10x_it.c、stm32f10x_conf.h
├── Start/               # 启动与 CMSIS 内核层
│   ├── startup_stm32f10x_md.s    # GNU 格式启动文件（矢量表 + 复位处理）
│   ├── core_cm3.h                # CMSIS 5 Cortex-M3 内核头文件
│   ├── cmsis_*.h                 # CMSIS 5 配套头文件
│   ├── stm32f10x.h               # STM32F10x 器件头文件
│   └── system_stm32f10x.c/.h     # 系统时钟初始化（当前目标 72MHz）
├── Library/             # STM32F10x 标准外设库（SPL）
│   ├── inc/             # 外设库头文件
│   └── src/             # 外设库源文件
├── Hardware/            # 板级驱动：LED、Key、OLED
├── System/              # 系统工具：Delay（us/ms/s 延时）
├── cmake/
│   └── gcc-arm-none-eabi.cmake   # ARM 交叉编译工具链文件
├── CMakeLists.txt
├── CMakePresets.json
├── STM32F103XX_FLASH.ld          # 链接脚本（64K Flash / 20K RAM）
├── stm32f103c8_blue_pill.cfg     # OpenOCD 烧录配置（ST-Link + SWD）
└── .gitignore
```

---

## 环境要求

| 工具 | 说明 |
|---|---|
| [STM32CubeCLT](https://www.st.com/en/development-tools/stm32cubeclt.html) 或 GNU Tools for STM32 | 提供 `arm-none-eabi-gcc` 交叉编译器 |
| CMake ≥ 3.22 | 构建系统 |
| Ninja | 构建工具（CLion 自带） |
| CLion（可选） | 集成开发环境，内置 CMake 与 OpenOCD 调试支持 |
| OpenOCD / STM32CubeProgrammer | 烧录工具（二选一） |
| ST-Link | SWD 下载器 |

---

## 常见问题

- **CLion 用 MinGW 编译器编译 ARM 代码报错**：CMake profile 没有使用 ARM 工具链。请确认在 CMake options 中填入了 `-DCMAKE_TOOLCHAIN_FILE=cmake/gcc-arm-none-eabi.cmake`，或使用 CMakePresets 的 Debug 预设。
- **构建报 `registers may not be the same`**：旧版 `core_cm3.c` 的 STREX 内联汇编与新 GCC 不兼容，本模板已通过 earlyclobber 约束（`"=&r"`）修复。
- **烧录报 `timed out while waiting for target halted`**：
  - 克隆版 ST-Link 与杜邦线易受速度影响，在配置中降低 `adapter speed`（如 500）
  - 若 NRST 未接线，使用软件复位：`reset_config none`（本模板 `stm32f103c8_blue_pill.cfg` 已配置）
- **烧录报连接失败**：检查 SWD 四根线是否接对；若芯片被读保护，用 CubeProgrammer 解锁：`STM32_Programmer_CLI -c port=SWD -ob RDP=0xAA`

---

## License

MIT
