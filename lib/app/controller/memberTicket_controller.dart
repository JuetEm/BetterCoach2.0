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

      if (!exists) memberTicketList.add(ticket);
    });

    /// 원래의 리스트에 새로운 것만 추가됨.
    globalList = memberTicketList;

    print('[MemberTicket] memberTicket Updated to Global Variables!');
  }
}
