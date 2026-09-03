"""Mini Redis 대화형 명령줄 인터페이스(CLI)."""

import sys
from typing import TextIO

from mini_redis.commands import CommandProcessor


PROMPT = "mini-redis> "


def run_cli(
    processor: CommandProcessor | None = None,
    input_stream: TextIO | None = None,
    output_stream: TextIO | None = None,
) -> None:
    """EOF, 인터럽트(키보드 중단), exit 또는 quit 입력 시까지 REPL을 실행합니다."""

    command_processor = processor if processor is not None else CommandProcessor()
    source = input_stream if input_stream is not None else sys.stdin
    destination = output_stream if output_stream is not None else sys.stdout

    while True:
        try:
            destination.write(PROMPT)
            destination.flush() # 출력 버퍼를 비워서 즉시 화면에 표시되도록 함
            line = source.readline()

            if line == "": # readline()은 EOF에서 빈 문자열 반환
                break

            output, should_exit = command_processor.execute(line) # 명령어를 실행하고 결과와 종료 여부를 반환
            if output is not None:
                destination.write(output + "\n")
                destination.flush()
            if should_exit:
                break
        except KeyboardInterrupt:
            destination.write("\n")
            destination.flush()
            break
