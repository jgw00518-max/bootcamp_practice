import 'package:flutter/material.dart';
import 'package:gridview_ex_app/model/animal_list.dart';

class FirstPage extends StatefulWidget {
  final List<Animal> list;

  const FirstPage({super.key, required this.list});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          itemCount: widget.list.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2열 배치
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.8,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _showDialog(index), // 👈 타일 클릭 시 _showDialog 실행
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(widget.list[index].imagePath),
                        radius: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.list[index].animalName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.list[index].kind,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  } // build

  // --- Functions ---
  void _showDialog(int index){
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            widget.list[index].animalName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          content: Row(
            children: [
              Image.asset(
                widget.list[index].imagePath,
                width: 50,
              ),
              Text(
                '이 동물은 ${widget.list[index].kind} 입니다. \n'
                '이 동물은 ${widget.list[index].flyExist ? "날 수 있습니다." : "날 수 없습니다."}'
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              }, 
              child: const Text('종료'),
            ),
          ],
        );
      },
    );
  }
  
} // class