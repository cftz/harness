# Linear Guide

## Intent

Linear 관련 작업 수행 시 일관된 행동 패턴을 보장하기 위한 가이드라인 스킬. MCP 대신 Skill 사용을 강제하고, 이슈 리스트 조회 시 필수 파라미터 명시를 요구합니다.

## Motivation

Linear 작업에서 발생하는 문제들:
1. MCP와 Skill이 혼재되어 일관성 없는 코드 생성
2. 이슈 리스트 조회 시 파라미터 누락으로 과도한 데이터 요청
3. 프로젝트/상태 필터 없이 전체 이슈를 가져오는 비효율

이 스킬은 이러한 문제를 방지하기 위한 행동 지침을 제공합니다.

## Design Decisions

1. **user-invocable: false**: 사용자가 직접 호출하는 것이 아니라 Linear 작업 시 자동으로 참조되는 지침
2. **Skill 우선 원칙**: MCP는 Skill이 지원하지 않는 기능에만 사용
3. **필수 파라미터 명시**: 이슈 리스트 조회 시 PROJECT_ID, STATE, FIRST 필수

## Constraints

- 이 스킬은 실제 Linear 작업을 수행하지 않음 (지침만 제공)
- 새로운 Linear Skill이 추가되면 이 문서도 업데이트 필요
- MCP 사용이 불가피한 경우는 예외로 허용
