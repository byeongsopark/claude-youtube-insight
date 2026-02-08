# Claude YouTube Insight Pipeline

YouTube 영상의 자막을 추출하고, Claude Code가 AI 분석을 통해 구조화된 인사이트 노트를 Obsidian 볼트에 자동 저장합니다.

## 기능

```
/youtube https://www.youtube.com/watch?v=VIDEO_ID
```

한 줄 명령으로:
1. YouTube 자막 추출 (한/영/일 자동 감지)
2. 7개 섹션 인사이트 분석 (핵심 요약, 인사이트, 상세 노트, 액션 아이템, 인용구, 비판적 시각)
3. Obsidian 노트로 자동 저장 (카테고리 자동 분류)

## 설치

### 사전 요구사항

- [Claude Code](https://claude.ai/claude-code) 설치 완료
- Python 3.10+
- Obsidian 볼트

### Windows

```powershell
git clone https://github.com/byeongsopark/claude-youtube-insight.git
cd claude-youtube-insight
powershell -ExecutionPolicy Bypass -File setup.ps1
```

### macOS / Linux

```bash
git clone https://github.com/byeongsopark/claude-youtube-insight.git
cd claude-youtube-insight
chmod +x setup.sh setup-vault.sh
./setup.sh
```

### Obsidian 볼트 폴더 생성 (최초 1회)

```bash
# macOS/Linux
./setup-vault.sh /path/to/your/vault

# Windows (PowerShell)
$vault = "C:\path\to\your\vault"
@("01_자기계발","02_투자","03_커리어","04_기술","05_비즈니스","99_기타") | ForEach-Object {
    New-Item -ItemType Directory -Force -Path "$vault\30_Resource\10_YouTube\$_"
}
```

## 파일 구조

```
~/.claude/
├── commands/
│   └── youtube.md              # /youtube 슬래시 커맨드
├── scripts/
│   └── youtube_transcript.py   # 자막 추출 Python 스크립트
├── skills/
│   ├── youtube-insight/        # AI 인사이트 분석 프레임워크
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── insight-templates.md
│   └── obsidian-writer/        # Obsidian 노트 작성 규칙
│       ├── SKILL.md
│       └── references/
│           ├── vault-structure.md
│           └── note-examples.md
└── settings/
    └── youtube-vault-path.txt  # Obsidian 볼트 경로 (setup 시 생성)
```

## 카테고리

| 카테고리 | 폴더 | 키워드 예시 |
|----------|------|-------------|
| 자기계발 | 01_자기계발 | 습관, 마인드셋, 생산성, 루틴 |
| 투자 | 02_투자 | 주식, 부동산, ETF, 경제 |
| 커리어 | 03_커리어 | 이직, 면접, 연봉, 직장 |
| 기술 | 04_기술 | 프로그래밍, AI, 개발, 자동화 |
| 비즈니스 | 05_비즈니스 | 창업, 마케팅, 브랜딩, 매출 |
| 기타 | 99_기타 | 위에 해당하지 않는 경우 |

## 의존성

- `youtube-transcript-api` (pip install)
