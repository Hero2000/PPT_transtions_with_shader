# PPT_Transtions
在OpenGL里用纯shader实现PPT的切换特效
直接点击 OpenGL.sln 用Visual Studio2019 打开工程生成即可

## 一、 淡入淡出 Fade
直接调用GLSL的mix函数即可

## 二、推入 Push
现象：一张图片从右往左把另一张图片推出屏幕
要点：
1、判断texCoord与u_ratio的大小，选择在左右两边显示哪张图
2、同时对两张图的texCoord做一定偏移

## 三、擦除 Wipe
现象：从右往左将上面一张图片擦除
思路：
主要还是依赖于mix函数进行混合，只不过在边缘处实现渐变，渐变的实现可简单用线性插值实现，从右往左的擦除就好比将一条斜线从右往左移动，随后clamp就成为了透明度alpha

## 四、分割 Split
现象：从中间往两边“擦除”
思路：类似于“把擦除等效为从右往左移动”，分割的实现可抽象为下图：
 
## 五、显示 Reveal
现象：先是从右往左，图片微微放大的同时屏幕变白，随后从左往右，另一张图片浮现，且微微缩小
要点：
1、	图片淡出淡入的效果与前面的擦除类似，只不过混合对象变成了白图
2、	图片缩放的实现，实现缩放时，要选择缩放中心，变换顺序为：先移动到缩放中心，执行缩放后，再从缩放中心移动回去

## 六、切入 Cut
现象：瞬间切换，很简单的效果

## 七、随机线条 RandomBars
现象：前一张图片消失于很多随机线条中，后一张图片浮现，就好比在多个随机位置处执行“分割”
思路：使用for循环对多个随机位置的“分割”透明度进行叠加，取多个函数的最小值：

## 八、形状 Shape
现象：由一个形状往四周扩散，下一张图片浮现
思路：仍然从“形状移动”的思路出发，考虑不同形状的透明度函数，只不过此时的函数变成二元函数了：

## 九、覆盖 Cover与 揭开 Uncover 
现象：一张图片从一个方向滑走，或者另一张图片滑入
要点：效果与“Push推入”很类似，只不过其中一张图片不进行顶点偏移而已

## 十、闪光 Flash
现象：类似于闪光灯闪的一下，就切换为另一张图片
要点：先将第一张图片的RGB迅速升高，成为全白图，然后全白状态下切换为第二张图，降低RGB值，使之正常

## 十一、溶解 Dissolve
现象：一张图溶解为许多小碎片，然后另一张图浮现
要点：
1、	将屏幕划分为多个小块，比如要划分为7*5个小块，就将xy乘以vec2(7,5)，然后取floor后除以vec2(7,5)既可
2、	然后每个小块设置不同的随机值，之前介绍了一维的伪随机数生成，这里可以使用二维的伪随机数生成，每个小块设置不同的随机值后，将其与u_ratio比较，决定其溶解与否

## 十二、翻转 Flip
现象：图片原地翻转，背面为另一张图片
要点；
1、	实现绕y轴的3D旋转和透视投影，用剪切（shear）替代投影实现
2、	一个小细节，在翻转的时候，图片往z方向有偏移量

## 十三、棋盘 CheckBoard
现象：生成许多小方块，各自翻页，背面为下一张图片
要点：
1、	将屏幕划分为多个小块，第十一中已介绍，且每个小块的翻页时间不一样，可加二维随机数
2、	每个小块的翻转操作，同十二中的翻转Flip操作

## 十三、百叶窗 Blinds
现象：类似广告百叶窗的切换，从三棱柱的一面旋转到另一面
要点：
1、	模拟三棱柱的旋转，将第一张图初始角度设置为0，第二张图初始角度设置为60度，同时绕虚拟三棱柱的轴，旋转120度
2、由于对于纹理坐标的变换和对顶点的坐标变换有所出入，所以实现的结果仍然有一些artifact，除了对三棱柱进行实实在在建模导入顶点坐标变换之外，没有想到好的办法

## 十四、时钟 Clock
现象：类似时钟的指针扫过一圈，同时便随着图片的消隐于浮现
要点：
1、	通过纹理坐标的xy值，计算角度
2、	对扫过的边缘添加渐变，前面在Wipe擦除中提到实现的渐变是用一个移动一个线性函数实现的，在这里，把角度当作自变量，同样用线性插值来实现渐变

## 十五、涟漪 Ripple
现象：类似水波纹像四周扩散，同时第二张图浮现出来
要点：
1、	水波纹最外层渐变的实现，类似于Shape形状里面的圆形
2、	水波纹对于图片的折射，可用sin函数来模拟水波
3、	水波纹波峰波谷的亮度变化，同样借助sin函数

## 十六、蜂巢 HoneyComb
现象：第一张图逐渐旋转变大，同时以蜂窝状逐个消失，同时第二张图以蜂窝状出现
要点：
1、	实现图片的旋转与缩放，比较简单
2、	在开始和结束时，用两个擦除的效果，比较简单，加到透明度上即可
3、	写出蜂窝状的形状，并对每个形状添加不同的随机值，这块比较复杂，详细讲解：
 
要实现的蜂窝状如图所示，我们知道，如果这些小块都是一个个矩形，那么就可以按照之前的思路容易生成，但是这些蜂窝状都是六边形，并且不像矩形那样排布很规则，我在此处介绍“最小拼接块”的思想：是否可以找到最小矩形拼接块，只要生成了这个拼接块的图案，然后复制即可？
 
可以看到，右边这个最小矩形拼接块，可以由两个六边形和一个长条矩形通过布尔运算获得，所以难点在于如何生成六边形？
我们知道长条矩形的生成很容易，那么怎样生成一个六边形呢？
用三个旋转角度不同的长条矩形求交集就可以！有了六边形和矩形，就可以对三个图形进行布尔运算，为此，专门为float类型写了and、or和not函数

 
