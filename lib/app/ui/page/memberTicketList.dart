import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:web_project/app/data/provider/memberTicket_service.dart';
import 'package:web_project/app/ui/widget/centerConstraintBody.dart';
import 'package:web_project/app/data/model/color.dart';
import 'package:web_project/app/data/model/globalVariables.dart';

class MemberTicketList extends StatefulWidget {
  MemberTicketList(this.memberId, this.ticketList, this.customFunction,
      {super.key});
      
  String memberId;
  List ticketList;
  Function customFunction;

  @override
  State<MemberTicketList> createState() => _MemberTicketListState();
}

class _MemberTicketListState extends State<MemberTicketList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MemberTicketService>(
      builder: (context, memberTicketService, child) {
        return Scaffold(
          body: Container(
            height: 500,
            width: 300,
            color: Palette.mainBackground,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // titleP
                SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: widget.ticketList.length,
                    itemBuilder: (context, index) {
                      if (widget.ticketList[index]['memberId'] ==
                          widget.memberId) {
                        return ListTile(
                          title: Text(widget.ticketList[index]['ticketTitle']),
                          trailing: IconButton(
                              onPressed: () {
                                var element;
                                for (int i = 0;
                                    i < widget.ticketList.length;
                                    i++) {
                                  element = widget.ticketList[i];
                                  if (element['id'] ==
                                      widget.ticketList[index]['id']) {
                                    memberTicketService.delete(
                                        docId: element['id'],
                                        onError: () {},
                                        onSuccess: () {});
                                    widget.ticketList.remove(element);
                                    break;
                                  }
                                }
                                widget.customFunction();
                              },
                              icon: Icon(Icons.clear)),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
