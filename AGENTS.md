# AGENTS.md — руководство для AI-агентов (OPM)

Документ для агентов, работающих с этим репозиторием. Цель — быстро понять архитектуру, где править код и как проверять изменения.

## Что это за проект

**OPM (OneScript Package Manager)** — менеджер пакетов для [OneScript](https://oscript.io): сборка `.ospx`, установка из хаба/файла/URL, разрешение зависимостей, публикация, scaffold и запуск задач.

- Репозиторий: https://github.com/oscript-library/opm
- Лицензия: Apache-2.0
- Версия продукта: `КонстантыOpm.ВерсияПродукта` (сейчас `1.1.2`)
- Требуемая среда: OneScript ≥ **1.8.3** (`packagedef`)
- Хабы: `http://hub.oscript.io`, запасной `http://hub.oscript.ru`
- Packaging docs: https://hub.oscript.io/packaging

## Стек

| Слой | Технология |
|------|------------|
| Язык | OneScript / BSL (`.os`), **русские** идентификаторы |
| CLI | пакет `cli` |
| Логи | `logos` (`oscript.app.opm`) |
| Unit | `1testrunner` |
| BDD | `1bdd` (Gherkin на русском) |
| Coverage | `coverage` + `oscript -codestat=` |
| CI | GitHub Actions + SonarQube (`sonar.openbsl.ru`) |

Runtime-зависимости — в корневом `packagedef`: `fs`, `asserts`, `fluent`, `logos`, `cli`, `tempfiles`, `gitrunner`, `reflector`.

## Структура репозитория

```
opm/
├── packagedef                 # манифест пакета OPM
├── src/
│   ├── cmd/
│   │   ├── opm.os             # точка входа CLI
│   │   ├── Классы/            # КомандаOpm_*.os, ИсполнительЗадач
│   │   └── Модули/            # ПараметрыПриложенияOpm
│   └── core/
│       ├── Классы/            # менеджеры, сборщик, установка...
│       └── Модули/            # КонстантыOpm, РаботаС*, НастройкиOpm
├── tasks/                     # opm run / opm test
│   ├── test.os                # unit + bdd
│   ├── coverage.os            # как в CI
│   └── oscript.cfg
├── tests/                     # unit-тесты (1testrunner)
├── features/                  # BDD (1bdd) + step_definitions/
├── .github/workflows/         # CI / release / rebase
└── oscript_modules/           # локальные зависимости (vendor, в .gitignore)
```

Отдельного каталога `docs/` нет — ориентир: `README.md` и этот файл.

## Архитектура (слои)

```
src/cmd/opm.os  (cli.КонсольноеПриложение)
  → КомандаOpm_*  (ОписаниеКоманды / ВыполнитьКоманду)
    → РаботаСПакетами / СборщикПакета / ИсполнительЗадач / ...
      → МенеджерУстановкиПакетов / МенеджерПолученияПакетов / УстановкаПакета / ...
```

### Карта «хочу изменить X»

| Задача | Куда смотреть |
|--------|----------------|
| CLI-команда / флаги | `src/cmd/opm.os`, `src/cmd/Классы/КомандаOpm_*.os` |
| Install / зависимости | `РаботаСПакетами`, `МенеджерУстановкиПакетов`, `УстановкаПакета`, `КэшУстановленныхПакетов` |
| Скачивание с хаба | `МенеджерПолученияПакетов`, `СерверПакетов`, `КонстантыOpm` |
| Сборка `.ospx` | `СборщикПакета`, `ОписаниеПакета`, `СериализацияМетаданныхПакета` |
| Publish | `КомандаOpm_Push` |
| Версии `Имя@Версия` | `РаботаСВерсиями` |
| Чтение `packagedef` | `РаботаСОписаниемПакета`, `ОписаниеПакета` |
| `opm.cfg` / прокси / зеркала | `ПараметрыПриложенияOpm`, `НастройкиOpm` |
| Версия продукта | `src/core/Модули/КонстантыOpm.os` (+ fallback в `packagedef`) |

### Команды CLI

| Команда | Класс |
|---------|-------|
| `a app` | `КомандаOpm_App` |
| `b build` | `КомандаOpm_Build` |
| `c config` | `КомандаOpm_Config` |
| `i install` | `КомандаOpm_Install` |
| `ls list` | `КомандаOpm_List` |
| `pre prepare` | `КомандаOpm_Prepare` |
| `p push` | `КомандаOpm_Push` |
| `r run` | `КомандаOpm_Run` |
| `test` | `КомандаOpm_Test` |
| `u update` | `КомандаOpm_Update` |
| `version` | `КомандаOpm_Version` |

### Потоки данных (кратко)

**Install:** CLI → `РаботаСПакетами` → download (`МенеджерПолученияПакетов`) → `УстановкаПакета` (unzip `.ospx`) → рекурсивные зависимости → кэш установленных.

**Build:** `СборщикПакета` читает `packagedef` (контекст `Описание` = fluent `ОписаниеПакета`) → hooks → `{Имя}-{Версия}.ospx` = ZIP(`opm-metadata.xml` + `content.zip`).

**Режимы установки:** локально → `./oscript_modules`; глобально → системный `lib` OneScript (`РежимУстановкиПакетов`).

## Окружение и команды

### Подготовка

```powershell
# Нужен OneScript ≥ 1.8.3 (stable или 1.8.4 как в CI)
opm install opm
opm install 1testrunner
opm install 1bdd
opm install coverage
opm install -l --dev
```

### Запуск из исходников

```powershell
oscript src\cmd\opm.os --help
oscript src\cmd\opm.os version
oscript src\cmd\opm.os install --local
oscript src\cmd\opm.os build --mf .\packagedef .
```

Отладка: `.vscode/launch.json`, `LOGOS_CONFIG=logger.oscript.app.opm=DEBUG`.

### Тесты

```powershell
oscript tasks\test.os          # unit + bdd
opm test                       # через CLI
```

Отчёты: каталог `out/`.

### Типовые CLI-вызовы

```powershell
opm install asserts
opm install --local            # зависимости packagedef → ./oscript_modules
opm install --local --dev
opm install -f my.ospx --local
opm install Package@1.2.0
opm build --mf .\packagedef .
opm list
opm list --remote
opm prepare my-package
opm update opm
```

Полезные переменные: `OSCRIPTBIN`, `OPM_HUB_MIRROR`, `OPM_HUB_CHANNEL`, `GITHUB_OAUTH_TOKEN`, `LOGOS_CONFIG`.

## Соглашения по коду

1. **Русский BSL** — имена процедур, переменных, каталогов `Классы/` / `Модули/`.
2. Пользовательские строки — не использовать `НСтр("ru='...';en='...')`.
3. Модули = статический API (`РаботаС*`, `КонстантыOpm`); классы = состояние (`Менеджер*`, `УстановкаПакета`).
4. Подключения: `#Использовать logos`, `#Использовать "../core"`, `#Использовать cli`.
5. Комментарии — на русском. Не рефакторить стиль «заодно», если задача этого не требует.

### Добавление CLI-команды

1. Создать `src/cmd/Классы/КомандаOpm_Foo.os` по образцу `КомандаOpm_Build.os`:
   - `ОписаниеКоманды(КомандаПриложения)` — опции и аргументы;
   - `ВыполнитьКоманду(КомандаПриложения)` — логика.
2. Зарегистрировать в `src/cmd/opm.os`:
   `Приложение.ДобавитьКоманду("f foo", НСтр(...), Новый КомандаOpm_Foo);`
3. При необходимости — unit/BDD и строка в `README.md`.

**Не копировать** `ШаблонКоманды.os-template` — там устаревший cmdline API. Актуальный паттерн — пакет `cli`, как в `КомандаOpm_Build.os`.

### Зависимости самого OPM

В корневом `packagedef`:

```bsl
.ЗависитОт("имя", "min.version")
.РазработкаЗависитОт("имя", "min.version")
```

Затем `opm install -l` / `opm install -l --dev`.

## Тесты: контракт

**Unit** (`tests/*.os`, 1testrunner):

- `ПолучитьСписокТестов(Тестирование)`
- `ПередЗапускомТеста` / `ПослеЗапускаТеста`
- методы `ТестДолжен_*`
- asserts: `#Использовать asserts`, `Ожидаем`

Файлы: `packagedef-test.os`, `versions-test.os`, `mft-serializer-test.os`, `pkg-cache.os`, `packagelist.os`, `download.os`, `build-install-test.os`.

**BDD** (`features/*.feature` + `features/step_definitions/*.os`, `# language: ru`):

- `opm-build.feature`, `install-file.feature`, `Настройки.feature`

При правках логики — добавляй/обновляй ближайший тест в той же области (см. карту выше).

Перед PR желательно прогнать `oscript tasks\test.os`.