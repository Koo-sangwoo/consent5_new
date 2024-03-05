import 'package:flutter/material.dart';



class DropDownBuilder extends StatefulWidget {

  final List<String> menuList;
  ///  @since 2024/02/14
  ///  @author sangU02
  ///  드롭다운 생성 클래스,
  ///  생성자 인자에 드롭다운 할 리스트를 넣으면됨.
  const DropDownBuilder({super.key, required this.menuList});

  @override
  State<DropDownBuilder> createState() => _DropDownBuilderState();
}

class _DropDownBuilderState extends State<DropDownBuilder> {
  @override
  Widget build(BuildContext context) {
    String value = widget.menuList[0];
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value!,
          icon: const Icon(
            Icons.expand_more,
            color: Colors.grey,
          ),
        decoration: InputDecoration(
          // 테두리 색상을 설정합니다. 이는 텍스트 필드가 활성화되지 않았을 때 적용됩니다.
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.grey
                    .withOpacity(0.5)), // 연한 빨간색 테두리
          ),
          // 텍스트 필드에 포커스가 있을 때의 테두리 색상을 설정합니다.
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.5)), // 연한 빨간색 테두리
          ),
          // 텍스트 필드를 편집할 수 없을 때의 테두리 색상을 설정합니다.
          // disabledBorder: OutlineInputBorder(
          //   borderSide: BorderSide(
          //       color: Colors.red.withOpacity(0.5)), // 연한 빨간색 테두리
          // ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 10),
        ),
        onChanged: (String? deptValue) {
          setState(() {
            value = deptValue!;
          });
        },
        items: widget.menuList
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style:  TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.5)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
