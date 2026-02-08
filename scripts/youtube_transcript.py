#!/usr/bin/env python3
"""YouTube 자막 추출 스크립트

YouTube URL에서 자막과 메타데이터를 추출하여 JSON으로 출력합니다.
Claude Code의 /youtube 슬래시 커맨드에서 호출됩니다.

사용법:
    python youtube_transcript.py <youtube-url>

의존성:
    pip install youtube-transcript-api
"""

import sys
import json
import re
import urllib.request
import urllib.error
import html

MAX_TEXT_LENGTH = 60000  # 긴 영상 텍스트 제한 (약 2시간 분량)

# 자막 언어 우선순위
LANGUAGE_PRIORITY = ["ko", "en", "ja"]


def extract_video_id(url: str) -> str | None:
    """YouTube URL에서 Video ID를 추출합니다.

    지원 형식:
        - https://www.youtube.com/watch?v=VIDEO_ID
        - https://youtu.be/VIDEO_ID
        - https://www.youtube.com/shorts/VIDEO_ID
        - https://youtube.com/embed/VIDEO_ID
        - https://www.youtube.com/watch?v=VIDEO_ID&list=...
    """
    patterns = [
        r"(?:youtube\.com/watch\?.*v=)([a-zA-Z0-9_-]{11})",
        r"(?:youtu\.be/)([a-zA-Z0-9_-]{11})",
        r"(?:youtube\.com/shorts/)([a-zA-Z0-9_-]{11})",
        r"(?:youtube\.com/embed/)([a-zA-Z0-9_-]{11})",
    ]

    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)

    return None


def fetch_metadata(video_id: str) -> dict:
    """영상 메타데이터(제목, 채널명)를 HTML 파싱으로 추출합니다."""
    title = ""
    channel = ""

    try:
        url = f"https://www.youtube.com/watch?v={video_id}"
        req = urllib.request.Request(
            url,
            headers={
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            },
        )
        with urllib.request.urlopen(req, timeout=15) as response:
            page_html = response.read().decode("utf-8", errors="replace")

        # 제목 추출
        title_match = re.search(
            r'<meta\s+name="title"\s+content="([^"]*)"', page_html
        )
        if title_match:
            title = html.unescape(title_match.group(1))
        else:
            title_match = re.search(r"<title>(.+?)(?:\s*-\s*YouTube)?</title>", page_html)
            if title_match:
                title = html.unescape(title_match.group(1))

        # 채널명 추출
        channel_match = re.search(
            r'"ownerChannelName"\s*:\s*"([^"]*)"', page_html
        )
        if channel_match:
            channel = html.unescape(channel_match.group(1))
        else:
            channel_match = re.search(
                r'<link\s+itemprop="name"\s+content="([^"]*)"', page_html
            )
            if channel_match:
                channel = html.unescape(channel_match.group(1))

    except Exception:
        pass  # 메타데이터 실패는 치명적이지 않음

    return {"title": title, "channel": channel}


def fetch_transcript(video_id: str) -> dict:
    """자막을 추출합니다. 언어 우선순위에 따라 시도합니다."""
    from youtube_transcript_api import YouTubeTranscriptApi
    from youtube_transcript_api._errors import (
        TranscriptsDisabled,
        NoTranscriptFound,
        VideoUnavailable,
    )

    ytt_api = YouTubeTranscriptApi()

    try:
        transcript_list = ytt_api.list(video_id)
    except TranscriptsDisabled:
        return {
            "success": False,
            "error": "TranscriptsDisabled",
            "message": "이 영상은 자막이 비활성화되어 있습니다.",
            "video_id": video_id,
        }
    except VideoUnavailable:
        return {
            "success": False,
            "error": "VideoUnavailable",
            "message": "영상을 찾을 수 없습니다. URL을 확인해주세요.",
            "video_id": video_id,
        }
    except Exception as e:
        return {
            "success": False,
            "error": type(e).__name__,
            "message": f"자막 목록 조회 실패: {e}",
            "video_id": video_id,
        }

    # 수동 자막 우선 시도
    selected_transcript = None
    selected_language = None

    for lang in LANGUAGE_PRIORITY:
        try:
            selected_transcript = transcript_list.find_transcript([lang])
            selected_language = lang
            break
        except NoTranscriptFound:
            continue

    # 수동 자막을 찾지 못하면 자동 생성 자막 시도
    if selected_transcript is None:
        try:
            generated = transcript_list.find_generated_transcript(LANGUAGE_PRIORITY)
            selected_transcript = generated
            selected_language = generated.language_code + " (auto)"
        except NoTranscriptFound:
            pass

    # 아무것도 못 찾으면 사용 가능한 첫 번째 자막 사용
    if selected_transcript is None:
        try:
            for transcript in transcript_list:
                selected_transcript = transcript
                selected_language = transcript.language_code
                if transcript.is_generated:
                    selected_language += " (auto)"
                break
        except Exception:
            pass

    if selected_transcript is None:
        return {
            "success": False,
            "error": "NoTranscriptFound",
            "message": "사용 가능한 자막이 없습니다.",
            "video_id": video_id,
        }

    # 자막 데이터 추출
    try:
        transcript_data = selected_transcript.fetch()
    except Exception as e:
        return {
            "success": False,
            "error": type(e).__name__,
            "message": f"자막 데이터 가져오기 실패: {e}",
            "video_id": video_id,
        }

    # 자막 항목을 딕셔너리 리스트로 변환
    transcript_entries = []
    for entry in transcript_data:
        transcript_entries.append(
            {
                "text": entry.text if hasattr(entry, "text") else entry.get("text", ""),
                "start": entry.start if hasattr(entry, "start") else entry.get("start", 0),
                "duration": entry.duration if hasattr(entry, "duration") else entry.get("duration", 0),
            }
        )

    # 전체 텍스트 조합
    full_text = " ".join(item["text"] for item in transcript_entries)
    truncated = False

    if len(full_text) > MAX_TEXT_LENGTH:
        full_text = full_text[:MAX_TEXT_LENGTH]
        truncated = True

    return {
        "success": True,
        "language": selected_language,
        "transcript": transcript_entries,
        "full_text": full_text,
        "word_count": len(full_text),
        "truncated": truncated,
    }


def main():
    if len(sys.argv) < 2:
        result = {
            "success": False,
            "error": "NoArgument",
            "message": "사용법: python youtube_transcript.py <youtube-url>",
            "video_id": None,
        }
        print(json.dumps(result, ensure_ascii=False))
        sys.exit(1)

    url = sys.argv[1].strip()
    video_id = extract_video_id(url)

    if not video_id:
        result = {
            "success": False,
            "error": "InvalidURL",
            "message": f"유효한 YouTube URL이 아닙니다: {url}",
            "video_id": None,
        }
        print(json.dumps(result, ensure_ascii=False))
        sys.exit(1)

    # 메타데이터 추출
    metadata = fetch_metadata(video_id)

    # 자막 추출
    transcript_result = fetch_transcript(video_id)

    if not transcript_result["success"]:
        transcript_result["title"] = metadata["title"]
        transcript_result["channel"] = metadata["channel"]
        print(json.dumps(transcript_result, ensure_ascii=False))
        sys.exit(1)

    # 성공 결과 조합
    output = {
        "success": True,
        "video_id": video_id,
        "title": metadata["title"],
        "channel": metadata["channel"],
        "language": transcript_result["language"],
        "transcript": transcript_result["transcript"],
        "full_text": transcript_result["full_text"],
        "word_count": transcript_result["word_count"],
        "truncated": transcript_result["truncated"],
    }

    print(json.dumps(output, ensure_ascii=False))


if __name__ == "__main__":
    main()
