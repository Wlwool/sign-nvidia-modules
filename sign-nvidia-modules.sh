#!/bin/bash
# Автоматическая подпись модулей NVIDIA при включённом Secure Boot
# Используется при обновлении ядра или драйвера

MOK_PRIV="/root/secure-mok/MOK.priv"
MOK_DER="/root/secure-mok/MOK.der"
SIGN_TOOL="/usr/src/linux-headers-$(uname -r)/scripts/sign-file"
MODULES=(nvidia nvidia_drm nvidia_modeset nvidia_uvm)

echo "Подписание модулей NVIDIA..."

# Проверка есть ли ключи
if [[ ! -f "$MOK_PRIV" ]] || [[ ! -f "$MOK_DER" ]]; then
    echo "[X] Ошибка: MOK-ключи не найдены в $MOK_PRIV и $MOK_DER"
    exit 1
fi

# Проверка наличия инструмента для подписи
if [[ ! -f "$SIGN_TOOL" ]]; then
    echo "[X] Ошибка: sign-file не найден. Установите linux-headers-$(uname -r)"
    exit 1
fi

# Подписывание каждого модуля
for mod in "${MODULES[@]}"; do
    MODPATH=$(modinfo -n "$mod" 2>/dev/null)
    
    if [[ -f "$MODPATH" ]]; then
        echo "Подписывание $mod -> $MODPATH"
        sudo "$SIGN_TOOL" sha256 "$MOK_PRIV" "$MOK_DER" "$MODPATH"
        
        if [[ $? -eq 0 ]]; then
            echo "$mod подписан успешно"
        else
            echo "Не удалось подписать $mod"
        fi
    else
        echo "Модуль $mod не найден, пропускаю"
    fi
done
