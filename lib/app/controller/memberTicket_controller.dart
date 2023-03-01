class MemberTicketController {
  MemberTicketController();

/** Ticket Manage의 수강권 리스트 중 새로 추가된 항목만 Global Vairables에 업로드, update(주는 리스트, 받는 리스트) */
  void update(List ticketList, List globalList) {
    //// 새로운 리스트 (추가용) 선언
    final memberTicketList = List.from(globalList);

    /// 업데이트된 티켓리스트에 포문 돌림
    ticketList.forEach((ticket) {
      /// 존재하는지 안하는지 확인하는 boolean 값 선언
      final exists = memberTicketList.any((t) => t['id'] == ticket['id']);

      print("###Bob t['id'] == ticket['id'],${exists}, ${ticket['id']}");

      if (!exists) memberTicketList.add(ticket);
    });

    /// 원래의 리스트에 새로운 것만 추가됨.
    globalList = memberTicketList;

    print('[MemberTicket] memberTicket Updated to Global Variables!');
  }

/** 
 * Ticket Manage의 티켓을 선택했을 때 선택한것은 활성, 나머지는 비활성 시켜주는 함수 / ticketSelect(멤버의 전체 티켓 리스트, 현재 상태의 티켓 리스트(active,expired), 글로벌 리스트, 인덱스) */

  void ticketSelect(List ticketList, List currentStateTicketList,
      List globalList, int index) {
    if (index >= currentStateTicketList.length) {
      return;
    }

    // 다른 모든 티켓의 선택 해제
    for (var element in ticketList) {
      element['isSelected'] = false;
    }

    // Tap한 티켓만 선택상태로 변경
    var item = ticketList.firstWhere(
        (element) => element['id'] == currentStateTicketList[index]['id'],
        orElse: () => null);
    // print('[isSelect] index를 찾아라 $index');
    // print('[isSelect] ### 여기는 함수 안이다 to ticketList $index');
    if (item != null) {
      item['isSelected'] = true;
    }

    var globalItem = globalList.firstWhere(
        (element) => element['id'] == currentStateTicketList[index]['id'],
        orElse: () => null);
    // print('[isSelect] index를 찾아라 $index');
    // print('[isSelect] ### 여기는 함수 안이다 to globalList $index');

    if (item != null) {
      globalItem['isSelected'] = true;
    }
  }
}
