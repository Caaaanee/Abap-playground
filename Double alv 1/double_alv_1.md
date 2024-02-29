# Docking / Splitter 활용
### 하나의 Screen 에 관련 정보 
#### Example 완제품 - 부품 - 자재 관련 정보 도출

* Flow logic
![alt text](<스크린샷 2024-02-29 143921.png>)

* 진행 순서
1. Docking - 화면에 닻을 올리는 작업을 진행한다. 

2. 각 정보에 맞게 화면을 위 아래 2분할.

3. Enter 액션을 취하면 정보 출력.

4. 1번 alv는 scarr / 2번 alv는 sbook

5. 1번 alv에서 carrid를 더블클릭하면 Screen 102번 이동 일치하는 항공사 스케쥴, 항공사 리스트 tab 출력.

6. 2번 alv에선 carrid를 더블클릭하면 Screen 102번 이동 후 일치하는 항공사 스케쥴, 항공사 리스트 tab 출력.

7. Customerid를 더블클릭 하면 Screen 101번 이동 후 Customer list 정보 출력


* 예외 사항
- 실험을 위한 splitter 이기에 sbook table 정보 조회 시 모든 key를 조건에 걸지 않았다. 이를 예외 사항으로 생각하고 확인해야 한다. 