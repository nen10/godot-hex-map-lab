# ADOPT-00 UX（process-user 体験）

対象 user: 以降の task を実装・self-review する executor（autopilot / 人）。

達成したい体験:
- self-review を書くとき、**「最初に何が見え、何を触ると何が起こるか」を必ず記録する欄**があり、空欄では UI/graph task を `COMPLETE` にできないと分かる。
- queue rules を読めば、**metric/test 通過だけでは UI/graph task を完了にできない**ことが一読で分かる。
- QA/Validate に投資を集中したり製品全体へ波及させてはならないと、規則として参照できる。

避ける体験:
- 「存在する/test が通る」だけで完了にできてしまう旧来の gate（前回失敗の再発）。
