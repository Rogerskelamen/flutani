import 'package:flutter/material.dart';

//
//// 做出打字机效果：
//
// 第一步：测试
// 检验能否用sizedBox控制Text的宽度:
// 定义一个组件来测试，将定义好的组件注册到MyApp的home成员中
// 确定需要传入的参数：height(这个很好定义，就是字体的大小fontSize)，width(这个非常关键，动画就是因为这个值的变化)
// 问题来了，我们如何确定width的值大小呢（动画效果是每次一个字一个字出现，也就是说每次的动画间隔就是一个字的宽度）
// 通过在网上搜索，这篇 https://cloud.tencent.com/developer/article/1637248 详细解释了字体高和行高
// 通过实验：汉字的字体的height行高默认是1.4倍，所以容器就可以直接用【字体大小】* 1.4 来定义
// 同时进行英文字母的测试之后，字母的行高height默认是字母大小fontSize的1.2倍
// 通过真机调试后，汉字还是有细微的差别，说明还是受到媒体设备的影响
// 然后对于汉字的宽度来说，其实就是fontSize的大小
// 那么参数已经得到得到，即fontSize，最后就是width: animation.value, height: fontSize * 1.4 (当然这个是汉字打字机效果)
//
// 第二步：万事俱备，只欠代码
// 设置一个TyperAnimation类，然后用_TyperAnimation来实现
// 在_TyperAnimation类中，我们需要传入的参数就是文字的内容，大小，文字的字数
// 这里面的文字字数我们可以通过文字内容直接得到，不用传值。
// 需要注意的就是动画的值 animation.value，begin值就是0，end不用说也就是fontSize * fontNum
// 但是我们的打字机效果是一次跳一个字，也就是每次跃迁一个fontSize值（这又是一个难题）
// 经过思考和查资料发现我需要重新定义一下curve的值，于是我们自己来写一个跃变的curve曲线 JumpCurve
// 这样我们在使用传入 curve时就传入_JumpCurve，然后传入我们的文字字数fontNum（终于解决）
//
// 第三步：完成实现动画效果的载体组件
// 设置一个ExpandWidth，也就是真正实施动画效果的组件
// 因为需要用SizedBox包裹，所以还是需要传入fontSize
//
// 第四步：测试，看是否会翻车
// 成功！
//
// 第五步：使用说明(暂时完成中文版，之后再考虑英文)
// 使用: TyperAnimation (String fontContent, double fontSize)


// ignore: use_key_in_widget_constructors
class TyperAnimation extends StatefulWidget {
  final String fontContent;
  final double fontSize;

  const TyperAnimation({Key? key, required this.fontContent, required this.fontSize}) : super(key: key);

  @override
  _TyperAnimation createState() => _TyperAnimation(fontContent: fontContent, fontSize: fontSize);
}

class _TyperAnimation extends State
    with SingleTickerProviderStateMixin {

  // animation 和 controller
  late Animation<double> animation;
  late AnimationController controller;

  final String fontContent;
  final double fontSize;
  late int fontNum = fontContent.length;  // 默认值就可以从文字内容得出

  _TyperAnimation({required this.fontContent, required this.fontSize});

  @override
  void initState() {
    super.initState();
    // 设置控制器的初始化值
    controller = AnimationController(
      // 持续时间
      duration: Duration(milliseconds: 2000 * ((fontNum / 10).floor() + 1)),
      vsync: this
    );

    // 不用设置曲线
    animation = CurvedAnimation(parent: controller, curve: _JumpCurve(num: fontNum));

    // 设置动画变动的值
    animation = Tween(begin: fontSize, end: fontSize * fontNum).animate(controller);

    // 正向启动动画
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ExpandWidth(
      animation: animation,
      // 传入需要的行高，即字体大小
      fontSize: fontSize,
      child: SizedBox(
        child: Text(
          fontContent,
          style: TextStyle(
            fontSize: fontSize
          ),
        )
      ),
    );
  }
}

// ignore: unused_element, must_be_immutable
class _JumpCurve extends Curve {
  final int num;
  late double _perStairY;
  late double _perStairX;

  // 构造器
  _JumpCurve({required this.num}) {
    _perStairY = 1.0 / (num - 1);
    _perStairX = 1.0 / num;
  }

  @override
  double transform(double t) {
    return _perStairY * (t / _perStairX).floor();
  }
}

// 设计字体宽高的包裹组件（真正实施动画的组件）
class ExpandWidth extends StatelessWidget {
  const ExpandWidth({ Key? key, required this.animation, required this.child, required this.fontSize }) : super(key: key);

  final double fontSize;

  final Widget? child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, child) {
        return SizedBox(
          width: animation.value,
          height: fontSize * 1.4,
          child: child
        );
      },
      child: child,
    );
  }
}

// 对中文的汉字进行打字机效果
class Typer extends StatelessWidget {
  const Typer({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: TyperAnimation(
        fontContent: '',
        fontSize: 30,
      ),
    );
  }
}