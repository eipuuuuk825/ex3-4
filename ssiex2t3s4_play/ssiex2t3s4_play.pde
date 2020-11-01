int g_Data_num = 3;
int g_Data_lng = 256;
float[][] g_Data = new float[g_Data_num][g_Data_lng];

float g_t = 0, g_dt = 0;
float[] g_a = {0, 0, 0} , g_ac = {0, 0, 0} , g_aw = {0, 0, 0} , g_af = {0, 0, 0} , g_av = {0, 0, 0};
float[] g_q = new float[4];
float[] g_hq = {0, 0, 0, 1};
float[] g_Euler = new float[3]; // psi, theta, phi
float[] g_b = {0, 0, 0, 0, 0};
PFont g_font;
final int VIEW_SIZE_X = 800, VIEW_SIZE_Y = 600;

String g_filename = "HandMotion0.csv";
//String g_filename = "MyMotion1.csv";
// String g_filename = "MyMotion2.csv";
String[] g_lines;
int g_ln = 0;
int g_h_flag = 0;

/* --------------------------------------------------------------------------- */
/* --------------------------------------------------------------------------- */

class Point
{
	float m_x, m_y, m_z;
	
	Point() {
		m_x = m_y = m_z = 0;
	}
	Point(float x, float y, float z) {
		m_x = x;
		m_y = y;
		m_z = z;
	}
	void get_pos() {
		m_x = modelX(0, 0, 0);
		m_y = modelY(0, 0, 0);
		m_z = modelZ(0, 0, 0);
	}
	
	PVector to_vec() {
		return new PVector(m_x, m_y, m_z);
	}
}

class MyBox
{
	Point[]m_p = new Point[8];
	float m_width2, m_height2, m_depth2;
	
	MyBox(int width_, int height_, int depth_) {
		for (int i = 0;i < m_p.length;i++)
			m_p[i] = new Point();
		m_width2 = width_ / 2.0;
		m_height2 = height_ / 2.0;
		m_depth2 = depth_ / 2.0;
		m_p[0] = new Point(m_width2, - m_height2, m_depth2);
		m_p[1] = new Point(m_width2, - m_height2, - m_depth2);
		m_p[2] = new Point(- m_width2, - m_height2, - m_depth2);
		m_p[3] = new Point(- m_width2, - m_height2, m_depth2);
		m_p[4] = new Point(m_width2, m_height2, m_depth2);
		m_p[5] = new Point(m_width2, m_height2, - m_depth2);
		m_p[6] = new Point(- m_width2, m_height2, - m_depth2);
		m_p[7] = new Point(- m_width2, m_height2, m_depth2);
	}
	
	void draw(color c) {
		fill(c);
		beginShape();
		vertex(m_p[0].m_x, m_p[0].m_y, m_p[0].m_z);
		vertex(m_p[1].m_x, m_p[1].m_y, m_p[1].m_z);
		vertex(m_p[2].m_x, m_p[2].m_y, m_p[2].m_z);
		vertex(m_p[3].m_x, m_p[3].m_y, m_p[3].m_z);
		endShape(CLOSE);
		beginShape();
		vertex(m_p[4].m_x, m_p[4].m_y, m_p[4].m_z);
		vertex(m_p[7].m_x, m_p[7].m_y, m_p[7].m_z);
		vertex(m_p[6].m_x, m_p[6].m_y, m_p[6].m_z);
		vertex(m_p[5].m_x, m_p[5].m_y, m_p[5].m_z);
		endShape(CLOSE);
		beginShape();
		vertex(m_p[0].m_x, m_p[0].m_y, m_p[0].m_z);
		vertex(m_p[3].m_x, m_p[3].m_y, m_p[3].m_z);
		vertex(m_p[7].m_x, m_p[7].m_y, m_p[7].m_z);
		vertex(m_p[4].m_x, m_p[4].m_y, m_p[4].m_z);
		endShape(CLOSE);
		beginShape();
		vertex(m_p[1].m_x, m_p[1].m_y, m_p[1].m_z);
		vertex(m_p[5].m_x, m_p[5].m_y, m_p[5].m_z);
		vertex(m_p[6].m_x, m_p[6].m_y, m_p[6].m_z);
		vertex(m_p[2].m_x, m_p[2].m_y, m_p[2].m_z);
		endShape(CLOSE);
		beginShape();
		vertex(m_p[0].m_x, m_p[0].m_y, m_p[0].m_z);
		vertex(m_p[4].m_x, m_p[4].m_y, m_p[4].m_z);
		vertex(m_p[5].m_x, m_p[5].m_y, m_p[5].m_z);
		vertex(m_p[1].m_x, m_p[1].m_y, m_p[1].m_z);
		endShape(CLOSE);
		beginShape();
		vertex(m_p[2].m_x, m_p[2].m_y, m_p[2].m_z);
		vertex(m_p[6].m_x, m_p[6].m_y, m_p[6].m_z);
		vertex(m_p[7].m_x, m_p[7].m_y, m_p[7].m_z);
		vertex(m_p[3].m_x, m_p[3].m_y, m_p[3].m_z);
		endShape(CLOSE);
		fill(g_DEFAULT_COLOR);
	}
	
	boolean is_collision(Point input) {
		PVector[]v = new PVector[8];
		for (int i = 0;i < v.length;i++)
			v[i] = m_p[i].to_vec();
		
		/* 辺にベクトルを張る */
		PVector v12 = v[1].sub(v[0]);
		PVector v14 = v[3].sub(v[0]);
		PVector v15 = v[4].sub(v[0]);
		PVector v73 = v[2].sub(v[6]);
		PVector v76 = v[5].sub(v[6]);
		PVector v78 = v[7].sub(v[6]);
		
		/* 法線ベクトルを定義 */
		PVector[]n = new PVector[6];
		n[0] = v14.cross(v12);
		n[1] = v78.cross(v76);
		n[2] = v15.cross(v14);
		n[3] = v76.cross(v73);
		n[4] = v12.cross(v15);
		n[5] = v73.cross(v78);
		for (int i = 0;i < n.length;i++) {
			n[i].normalize();
			n[i].mult(300);
		}
		
		/* ローカル座標での中心の位置ベクトル */
		Point center = new Point();
		center.get_pos();
		PVector local_input = w2l(input.to_vec());
		
		/* 衝突判定用のベクトル */
		PVector l1 = new PVector(local_input.x - v[0].x, local_input.y - v[0].y, local_input.z - v[0].z);
		PVector l7 = new PVector(local_input.x - v[6].x, local_input.y - v[6].y, local_input.z - v[6].z);
		
		/* 衝突判定 */
		float[]sc = new float[6];/* 内積 */
		sc[0] = l1.dot(n[0]);
		sc[1] = l7.dot(n[1]);
		sc[2] = l1.dot(n[2]);
		sc[3] = l7.dot(n[3]);
		sc[4] = l1.dot(n[4]);
		sc[5] = l7.dot(n[5]);
		
		/*-----------------------------------------------
		表示
		-----------------------------------------------*/
		/* 判定対象を線分で表示 */
		drawLine(v[0], local_input, #00ff00);
		drawLine(v[6], local_input, #00ff00);
		/* 表示する法線ベクトルの色を決定 */
		color[]n_c = new color[6];
		for (int i = 0;i < sc.length;i++) {
			if (sc[i] > 0)
				n_c[i] = #ffffff;
			else
				n_c[i] = #ff0000;
		}
		drawLine(v[0], PVector.add(v[0], n[0]), n_c[0]);
		drawLine(v[6], PVector.add(v[6], n[1]), n_c[1]);
		drawLine(v[0], PVector.add(v[0], n[2]), n_c[2]);
		drawLine(v[6], PVector.add(v[6], n[3]), n_c[3]);
		drawLine(v[0], PVector.add(v[0], n[4]), n_c[4]);
		drawLine(v[6], PVector.add(v[6], n[5]), n_c[5]);
		
		
		// println("頂点");
		// for (int i = 0;i < m_p.length;i++)
		// 	println(m_p[i].to_vec());
		// println("辺のベクトル");
		// println("v12 " + v12);
		// println("v14 " + v14);
		// println("v15 " + v15);
		// println("v73 " + v73);
		// println("v76 " + v76);
		// println("v78 " + v78);
		// println("法線ベクトル");
		// for (int i = 0;i < 6;i++)
		// 	println(n[i]);
		// println("手先");
		// println(local_input);
		// println("内積計算用");
		// println(l1);
		// println(l7);
		// exit();
		
		
		
		for (int i = 0;i < sc.length;i++) 
			if (sc[i] > 0)
				return false;
		
		return true;
	}
}

class Yubi
{
	Point m_p = new Point();
	color m_c; 	/* 衝突時の色 */
	float m_b; 	/* 屈伸度合い */
	
	Yubi(color c) {m_c = c;}
	
	void get_pos() {
		m_p.m_x = modelX(0, 0, 0);
		m_p.m_y = modelY(0, 0, 0);
		m_p.m_z = modelZ(0, 0, 0);
	}
	
	float get_dist(Point p) {
		return dist(p.m_x, p.m_y, p.m_z, 
			m_p.m_x, m_p.m_y, m_p.m_z);
	}
}

class Obstacle
{
	float m_r;
	
	Obstacle(float r_self) {m_r = r_self;}
	
	void draw(Yubi yubi[]) {
		fill(g_DEFAULT_COLOR);
		Point center = new Point();
		center.get_pos();
		
		for (int i = 0; i < yubi.length; i++) {
			if (yubi[i].get_dist(center) < this.m_r) {
				fill(yubi[i].m_c);
				break;
			}
		}
		sphere(m_r);
		fill(g_DEFAULT_COLOR);
	}
}

class Queue
{
	int m_n;
	int m_len;
	float[] m_d;
	
	Queue(int n)
	{
		m_n = n;
		m_len = 0;
		m_d = new float[m_n];
	}
	
	void p()
	{
		for (int i = 0;i < m_len;i++)
			print(m_d[i] + " ");
		println();
	}
	
	void push(float d)
	{
		if (m_len == m_n)
		{
			for (int i = 0;i < m_n - 1;i++)m_d[i] = m_d[i + 1];
			m_d[m_n - 1] = d;
		}
		else
		{
			m_d[m_len] = d;
			m_len++;
		}
	}
}

class MAF/* 移動平均フィルタ */
{
	Queue m_q;
	
	MAF(int n) {m_q = new Queue(2 * n + 1);}
	
	void p() {m_q.p();}
	void push(float d) {m_q.push(d);}
	
	float get()
	{
		if (m_q.m_len < m_q.m_n)
			return 0;
		
		float sum = 0;
		for (int i = 0;i < m_q.m_len;i++)
			sum += m_q.m_d[i];
		return sum / m_q.m_len;
	}
}

class LPF/* ローパスフィルタ */
{
	float m_a;	/* 重み */
	float m_pre;/* 一つ前の値 */
	
	LPF(float a) {
		if (a <= 0 || 1 <= a) {
			println("a には 0 ~ 1 の値を指定してください．");
			exit();
		}
		m_a = a;
		m_pre = 0;
	}
	
	float calc(float d)
	{
		float ret = m_pre * m_a + d * (1 - m_a);
		m_pre = ret;
		return ret;
	}
}

/* b の正規化 */
float[] g_b_max = {0, 0, 0, 0, 0};
float[] g_b_min = {20, 20, 20, 20, 20};

/* param */
final float g_INIT_BEND1 = PI * 0.02; 	/* 骨１の初期屈伸角度 */
final float g_INIT_BEND2 = PI * 0.04; 	/* 骨２の初期屈伸角度 */
final color g_DEFAULT_COLOR = #777777; 	/* 通常時の色 */
final color g_HAND_COLOR = #888888; 		/* 手の色 */
final int g_YUBI_OYA = 0;
final int g_YUBI_HITO = 1;
final int g_YUBI_NAKA = 2;
final float g_HAND_SIZE = 500; 	/* 手の大きさ */

/* 指 */
Yubi[] g_yubi = {
	new Yubi(#ff0000), 
		new Yubi(#00ff00), 
		new Yubi(#0000ff)
	};

/* 障害物 */
Obstacle g_obs1 = new Obstacle(80);
Obstacle g_obs2 = new Obstacle(50);
Obstacle g_obs3 = new Obstacle(80);
MyBox g_box = new MyBox(300, 100, 300);

/* 平滑化 */
PrintWriter g_output_file;	/* 平滑化結果出力用 */
// MAF[]g_filtered_a = {new MAF(2), new MAF(2), new MAF(2)};
LPF[]g_filtered_a = {new LPF(0.5), new LPF(0.5), new LPF(0.5)};

PMatrix3D g_w2g;

/*-----------------------------------------------
*
* 行列を出力
*
-----------------------------------------------*/
void printMat(PMatrix3D mat) {
	pushMatrix();
	resetMatrix();
	applyMatrix(mat);
	printMatrix();
	popMatrix();
}

/*-----------------------------------------------
*
* ウィンドウ座標系からローカル座標系へ変換
*
-----------------------------------------------*/
PVector w2l(PVector v_w) {
	PMatrix3D w2g = g_w2g;
	
	PMatrix3D g2l = (PMatrix3D)getMatrix();
	g2l.invert();
	
	PVector v_g = new PVector();
	PVector v_l = new PVector();
	w2g.mult(v_w, v_g);
	g2l.mult(v_g, v_l);
	
	return v_l;
}

void drawLine(PVector s, PVector e, color c) {
	stroke(c);
	line(s.x, s.y, s.z, e.x, e.y, e.z);
	noStroke();
}

/*-----------------------------------------------
*
*障害物を描画
*
-----------------------------------------------*/
void drawObstacle() {
	pushMatrix();
	translate(VIEW_SIZE_X / 2 - 100, VIEW_SIZE_Y / 2 + 100, - 200);
	
	/* 球 */
	// pushMatrix();
	// translate( - 200,  - 50, - 300);
	// g_obs1.draw(g_yubi);
	// popMatrix();
	// pushMatrix();
	// translate(- 100,  + 75, - 10);
	// g_obs2.draw(g_yubi);
	// popMatrix();
	// pushMatrix();
	// translate( + 125,  + 290, - 300);
	// g_obs3.draw(g_yubi);
	// popMatrix();
	
	/* 直方体 */
	pushMatrix();
	// rotateX(- PI * 0.1);
	rotateY(- PI * 0.1);
	rotateZ( PI * 0.05);
	translate( - 200, 0, 0);
	if (g_box.is_collision(g_yubi[g_YUBI_HITO].m_p)) 
		g_box.draw(#ff0000);
	else
		g_box.draw(g_DEFAULT_COLOR);
	// g_box.is_collision(g_yubi[g_YUBI_HITO].m_p);
	popMatrix();
	
	popMatrix();
}

/*-----------------------------------------------
*
*手を描画
*
-----------------------------------------------*/
void drawHand() {  
	noStroke();
	ambientLight(189, 189, 189);
	lightSpecular(255, 255, 255);
	directionalLight(102, 102, 102, 1, 1, 1);
	specular(255, 255, 255);
	shininess(5.0);
	
	pushMatrix();
	translate(VIEW_SIZE_X / 2 + 100, VIEW_SIZE_Y / 2 , 0);
	// translate(VIEW_SIZE_X / 2, VIEW_SIZE_Y / 2, 100);
	rotateZ(- g_Euler[2]);
	rotateY(- g_Euler[0]);
	rotateX(- g_Euler[1]);
	rotateY(PI);				/* 必要な回転 */
	
	// rotateX(PI * 0.2); 		/* 見やすくするために回転 */
	rotateY(PI * 0.25);	/* 見やすくするための回転 */
	// rotateZ( - PI * 0.3);	/* 見やすくするために回転 */
	
	final float d = g_HAND_SIZE * 0.05;
	fill(#ffffff);
	drawOya(g_HAND_SIZE, d);
	drawHito(g_HAND_SIZE, d);
	drawNaka(g_HAND_SIZE, d);
	drawKusuri(g_HAND_SIZE, d);
	drawKo(g_HAND_SIZE, d);
	fill(g_DEFAULT_COLOR);
	
	popMatrix();
}

/*-----------------------------------------------
*
*親指を描画
*
-----------------------------------------------*/
void drawOya(float hand_size, float d) {
	final float h_hira = hand_size * 0.19;
	final float h_1 = h_hira * 0.9;
	final float h_2 = h_1 * 0.8;
	
	final float d_hira = d * 0.7;
	final float d_1 = d_hira * 0.8;
	final float d_2 = d_1 * 0.8;
	
	pushMatrix();
	/* hira */
	rotateY(PI * 0.12);
	rotateX(- PI * 0.1);
	translate(hand_size * 0.08, 0, hand_size * 0.14);
	drawBone(d_hira, h_hira);
	/* 1 */
	translate(0, 0, h_hira);
	rotateY( - PI * 0.1);
	rotateY(- g_yubi[g_YUBI_OYA].m_b * PI * 0.2);/* 屈伸 */
	drawBone(d_1, h_1);
	/* 2 */
	translate(0, 0, h_1);
	rotateY(- g_yubi[g_YUBI_OYA].m_b * PI * 0.5);/* 屈伸 */
	drawBone(d_2, h_2);
	/* 座標取得 */
	translate(0, 0, h_2);
	g_yubi[g_YUBI_OYA].get_pos();
	popMatrix();
}

/*-----------------------------------------------
*
*人差し指を描画
*
-----------------------------------------------*/
void drawHito(float hand_size, float d) {
	final float h_hira = hand_size * 0.38;
	final float h_1 = h_hira * 0.55;
	final float h_2 = h_1 * 0.8;
	final float h_3 = h_2 * 0.9;
	
	final float d_hira = d;
	final float d_1 = d_hira * 0.5;
	final float d_2 = d_1 * 0.8;
	final float d_3 = d_2 * 0.9;
	
	pushMatrix();
	/* hira */
	translate(hand_size * 0.08, 0, hand_size * 0.11);
	rotateY(PI * 0.037);
	drawBone(d_hira, h_hira);
	/* 1 */
	translate(0, 0, h_hira);
	rotateY( - PI * 0.04);
	rotateX(- g_INIT_BEND1);
	rotateX(- g_yubi[g_YUBI_HITO].m_b * PI * 0.1);/* 屈伸 */
	drawBone(d_1, h_1);
	/* 2 */
	translate(0, 0, h_1);
	rotateY(PI * 0.005);
	rotateX(- g_INIT_BEND2);
	rotateX(- g_yubi[g_YUBI_HITO].m_b * PI * 0.52);/* 屈伸 */
	drawBone(d_2, h_2);
	/* 3 */
	translate(0, 0, h_2);
	rotateY(PI * 0.005);
	rotateX(- g_yubi[g_YUBI_HITO].m_b * PI * 0.5);/* 屈伸 */
	drawBone(d_3, h_3);
	/* 座標取得 */
	translate(0, 0, h_3);
	g_yubi[g_YUBI_HITO].get_pos();
	popMatrix();
}

/*-----------------------------------------------
*
*中指を描画
*
-----------------------------------------------*/
void drawNaka(float hand_size, float d) {
	final float h_hira = hand_size * 0.45;
	final float h_1 = h_hira * 0.5;
	final float h_2 = h_1 * 0.8;
	final float h_3 = h_2 * 0.9;
	
	final float d_hira = d * 1.1;
	final float d_1 = d_hira * 0.5;
	final float d_2 = d_1 * 0.8;
	final float d_3 = d_2 * 0.9;
	
	pushMatrix();
	/* hira */
	translate(0, 0, hand_size * 0.05);
	rotateY(PI * 0.02);
	drawBone(d_hira, h_hira);
	/* 1 */
	translate(0, 0, h_hira);
	rotateY(- PI * 0.02);
	rotateX( - g_yubi[g_YUBI_NAKA].m_b * PI * 0.1);/* 屈伸 */
	drawBone(d_1, h_1);
	/* 2 */
	translate(0, 0, h_1);
	rotateX(- g_INIT_BEND2);
	rotateX( - g_yubi[g_YUBI_NAKA].m_b * PI * 0.52);/* 屈伸 */
	drawBone(d_2, h_2);
	/* 3 */
	translate(0, 0, h_2);
	rotateX( - g_yubi[g_YUBI_NAKA].m_b * PI * 0.45);/* 屈伸 */
	drawBone(d_3, h_3);
	/* 座標取得 */
	translate(0, 0, h_3);
	g_yubi[g_YUBI_NAKA].get_pos();
	popMatrix();
}

/*-----------------------------------------------
*
*薬指を描画
*
-----------------------------------------------*/
void drawKusuri(float hand_size, float d) {
	final float h_hira = hand_size * 0.39;
	final float h_1 = h_hira * 0.5;
	final float h_2 = h_1 * 0.8;
	final float h_3 = h_2 * 0.9;
	
	final float d_hira = d;
	final float d_1 = d_hira * 0.5;
	final float d_2 = d_1 * 0.8;
	final float d_3 = d_2 * 0.9;
	
	pushMatrix();
	/* hira */
	translate(- hand_size * 0.08, 0, hand_size * 0.11);
	rotateY(- PI * 0.01);
	drawBone(d_hira, h_hira);
	/* 1 */
	translate(0, 0, h_hira);
	rotateY(PI * 0.01);
	rotateX(- g_INIT_BEND1);
	drawBone(d_1, h_1);
	/* 2 */
	translate(0, 0, h_1);
	rotateX(- g_INIT_BEND2);
	drawBone(d_2, h_2);
	/* 3 */
	translate(0, 0, h_2);
	drawBone(d_3, h_3);
	popMatrix();
}

/*-----------------------------------------------
*
*小指を描画
*
-----------------------------------------------*/
void drawKo(float hand_size, float d) {
	final float h_hira = hand_size * 0.38;
	final float h_1 = h_hira * 0.4;
	final float h_2 = h_1 * 0.8;
	final float h_3 = h_2 * 0.9;
	
	final float d_hira = d;
	final float d_1 = d_hira * 0.45;
	final float d_2 = d_1 * 0.8;
	final float d_3 = d_2 * 0.9;
	
	pushMatrix();
	/* hira */
	translate(- hand_size * 0.08 * 2, 0, hand_size * 0.12);
	rotateY(- PI * 0.035);
	drawBone(d_hira, h_hira);
	/* 1 */
	translate(0, 0, h_hira);
	rotateY(PI * 0.037);
	rotateX(- g_INIT_BEND1);
	drawBone(d_1, h_1);
	/* 2 */
	translate(0, 0, h_1);
	rotateY(PI * 0.01);
	rotateX(- g_INIT_BEND2);
	drawBone(d_2, h_2);
	/* 3 */
	translate(0, 0, h_2);
	rotateY(PI * 0.01);
	drawBone(d_3, h_3);
	popMatrix();
}

/*-----------------------------------------------
*
*軸の方向を確認するためのオブジェクトを描画
*
-----------------------------------------------*/
void check_axis()
{
	pushMatrix();
	fill(g_DEFAULT_COLOR);
	sphere(30);
	translate(0, 0, 50);
	fill(#0000ff);
	sphere(10);/* z */
	translate(50, 0, - 50);
	fill(#ff0000);
	sphere(10);/* x */
	translate( - 50, 50, 0);
	fill(#00ff00);
	sphere(10);/* y */
	popMatrix();
}

/* --------------------------------------------------------------------------- */
/* --------------------------------------------------------------------------- */

void getVals() {  
	String[] co = split(g_lines[g_ln], ',');
	if (g_ln + 1 < g_lines.length - 1) g_ln++;
	g_dt = float(co[0]);
	g_t += g_dt;
	g_output_file.print(g_t + ",");
	
	/*-----------------------------------------------
	a
	-----------------------------------------------*/
	/* MAF */
	// for (int i = 0; i < 3; i++) {
	// 	g_filtered_a[i].push(float(co[i + 1]));
	// 	g_a[i] = g_filtered_a[i].get();
	// 	g_output_file.print(float(co[i + 1]) + ",");
	// }
	/* LPF */
	for (int i = 0; i < 3; i++) {
		g_output_file.print(float(co[i + 1]) + ",");
		g_a[i] = g_filtered_a[i].calc(float(co[i + 1]));
	}
	/* その他出力 */
	for (int i = 0;i < 3;i++) {
		g_output_file.print(g_a[i] + ",");
	}
	g_output_file.println();
	
	for (int i = 0; i < 4; i++) g_q[i] = float(co[i + 4]);
	for (int i = 0; i < 5; i++) g_b[i] = float(co[i + 8]);
	for (int i = 0; i < 5; i++) if (g_b[i] > 20.0) g_b[i] = 20.0;
	g_h_flag  = int(co[13]);
	delay(80);
	
	/* b seikika */
	final int YUBI_OYA = 3;
	final int YUBI_HITO = 2;
	final int YUBI_NAKA = 1;
	
	for (int i = 0; i < 5; i++) {
		if (g_b[i] > g_b_max[i])g_b_max[i] = g_b[i];
		if (g_b[i] < g_b_min[i])g_b_min[i] = g_b[i];
		float norm = (g_b[i] - g_b_min[i]) / (g_b_max[i] - g_b_min[i]); 
		switch(i)
		{
			case YUBI_OYA:
			g_yubi[g_YUBI_OYA].m_b = norm;
			break;
			case YUBI_HITO:
			g_yubi[g_YUBI_HITO].m_b = norm;
			break;
			case YUBI_NAKA:
			g_yubi[g_YUBI_NAKA].m_b = norm;
			break;
		}
	}
}

void draw() {
	background(#000000);
	fill(#ffffff);
	g_w2g = (PMatrix3D)getMatrix();
	
	getVals();
	
	if (g_h_flag == 1) {
		g_hq = quatConjugate(g_q);
		
		for (int i = 0; i < 3; i++) {
			g_ac[i] = 0;
			g_aw[i] = 0;
			g_af[i] = 0;
			g_av[i] = 0;
		}
	}
	
	if (g_hq != null) { // use home quaternion
		quaternionToEuler(quatProd(g_hq, g_q), g_Euler);
		// text("Disable home position by pressing \"n\"", 20, VIEW_SIZE_Y - 30);
	} else {
		quaternionToEuler(g_q, g_Euler);
		// text("Point FreeIMU's X axis to your monitor then press \"h\"", 20, VIEW_SIZE_Y - 30);
	}
	
	for (int i = 0; i < 3; i++) g_ac[i] = g_a[i] * (9.8 / 272.5);
	g_aw = quatTranslate(g_ac); // 0;-z, 1:-x, 2:-y
	for (int i = 0; i < 3; i++) g_af[i] = - g_aw[i]; // (2*g_af[i] + (-1)*g_aw[i] - 0)/3;
	g_av[0] = - g_af[0];
	g_av[1] = - g_af[1] + 9.61;
	g_av[2] = - g_af[2];
	
	drawStr();
	// drawGraph();	
	
	drawHand();
	drawObstacle();
}

void drawStr() {
	textFont(g_font, 20);
	textAlign(LEFT, TOP);
	text("Acc. : [" + nfs(g_av[0], 0, 2) + ", " + nfs(g_av[1], 0, 2) + ", " + nfs(g_av[2], 0, 2) + "]\n" +
		"Time : " + nfs(g_t, 0, 2) + "[s]", 20, 20);
	text("Euler angles : \n" + 
		"Yaw(psi)  : "   + nfs(degrees(g_Euler[0]), 0, 2) + "\n" + 
		"Pitch(theta) : " + nfs(degrees(g_Euler[1]), 0, 2) + "\n" + 
		"Roll(phi)  : "  + nfs(degrees(g_Euler[2]), 0, 2), 350, 20);
	text("Flexions : \n" + nfs(g_yubi[g_YUBI_OYA].m_b, 0, 2) + "\n" + nfs(g_yubi[g_YUBI_HITO].m_b, 0, 2) + "\n" + nfs(g_yubi[g_YUBI_NAKA].m_b, 0, 2), 600, 20);
}

void drawGraph() {
	int igx = 20, igy = 200, ghh = 50, scl = 2;
	for (int i = 0; i < g_Data_num; i++) {
		stroke(0, 255, 0);
		for (int j = 0; j < g_Data_lng - 1; j++) {
			g_Data[i][j] = g_Data[i][j + 1];
			if (j == g_Data_lng - 2) g_Data[i][j + 1] = g_av[i];
			line(j + igx, - g_Data[i][j] * scl + igy + ghh * (2 * i + 1), j + 1 + igx, - g_Data[i][j + 1] * scl + igy + ghh * (2 * i + 1));
		}
		stroke(255, 255, 255);
		line(igx, igy + ghh * (2 * i + 1) - 45, igx, igy + ghh * (2 * i + 1) + 45);
		line(igx, igy + ghh * (2 * i + 1), igx + 5, igy + ghh * (2 * i + 1));
	}
	stroke(0, 0, 0);
}

float decodeFloat(String inString) {
	byte[] inData = new byte[4];
	
	if (inString.length() == 8) {
		inData[0] = (byte) unhex(inString.substring(0, 2));
		inData[1] = (byte) unhex(inString.substring(2, 4));
		inData[2] = (byte) unhex(inString.substring(4, 6));
		inData[3] = (byte) unhex(inString.substring(6, 8));
	}
	
	int intbits = (inData[3] << 24) | ((inData[2] & 0xff) << 16) | ((inData[1] & 0xff) << 8) | (inData[0] & 0xff);
	return Float.intBitsToFloat(intbits);
}

void keyPressed() {
	if (key == 'h') {
		println("pressed h");
		
		// set g_hq the home quaternion as the quatnion conjugate coming from the sensor fusion
		g_hq = quatConjugate(g_q);
		
		for (int i = 0; i < 3; i++) {
			g_ac[i] = 0;
			g_aw[i] = 0;
			g_af[i] = 0;
			g_av[i] = 0;
		}
	} else if (key == 'n') {
		println("pressed n");
		g_hq = null;
	}
}

void quaternionToEuler(float[] q, float[] euler) {
	euler[0] = atan2(2 * q[1] * q[2] - 2 * q[0] * q[3], 2 * q[0] * q[0] - 2 * q[1] * q[1] - 1);
	euler[1] = - asin(2 * q[1] * q[3] + 2 * q[0] * q[2]);
	euler[2] = atan2(2 * q[2] * q[3] - 2 * q[0] * q[1], 2 * q[0] * q[0] + 2 * q[3] * q[3] - 1);
}

float[] quatProd(float[] a, float[] b) {
	float[] q = new float[4];
	
	q[0] = a[0] * b[0] - a[1] * b[1] - a[2] * b[2] - a[3] * b[3];
	q[1] = a[0] * b[1] + a[1] * b[0] + a[2] * b[3] - a[3] * b[2];
	q[2] = a[0] * b[2] - a[1] * b[3] + a[2] * b[0] + a[3] * b[1];
	q[3] = a[0] * b[3] + a[1] * b[2] - a[2] * b[1] + a[3] * b[0];
	
	return q;
}

// return the quaternion conjugate of quat
float[] quatConjugate(float[] quat) {
	float[] conj = new float[4];
	
	conj[0] = quat[0];
	conj[1] = - quat[1];
	conj[2] = - quat[2];
	conj[3] = - quat[3];
	
	return conj;
}

// Translate a point vector from senseor local co. sys. to real world co. sys. by using quaternion
float[] quatTranslate(float[] x) {
	float[] y = new float[3];
	
	y[2] = - ((sq(g_q[0]) + sq(g_q[1]) - sq(g_q[2]) - sq(g_q[3])) * x[0] + 2 * (g_q[1] * g_q[2] - g_q[0] * g_q[3]) * x[1] + 2 * (g_q[1] * g_q[3] + g_q[0] * g_q[2]) * x[2]);
	y[0] = - (2 * (g_q[1] * g_q[2] + g_q[0] * g_q[3]) * x[0] + (sq(g_q[0]) - sq(g_q[1]) + sq(g_q[2]) - sq(g_q[3])) * x[1] + 2 * (g_q[2] * g_q[3] - g_q[0] * g_q[1]) * x[2]);
	y[1] = - (2 * (g_q[1] * g_q[3] - g_q[0] * g_q[2]) * x[0] + 2 * (g_q[2] * g_q[3] + g_q[0] * g_q[1]) * x[1] + (sq(g_q[0]) - sq(g_q[1]) - sq(g_q[2]) + sq(g_q[3])) * x[2]);
	
	return y;
}

// http://vormplus.be/blog/article/drawing-a-cylinder-with-processing
void drawBone(float r2, float h) {
	final int sides = 10;
	final float r1 = 0;
	
	final float sphere_rate = 0.5;
	float sphere_r = r2 * sphere_rate;
	float cylinder_h = h - sphere_r;
	
	float angle = 360 / sides;
	float halfHeight = cylinder_h / 2;
	
	pushMatrix();
	sphere(sphere_r);
	translate(0, 0, sphere_r + halfHeight);
	// top
	beginShape();
	for (int i = 0; i < sides; i++) {
		float x = cos(radians(i * angle)) * r2;
		float y = sin(radians(i * angle)) * r2;
		vertex(x, y, - halfHeight);
	}
	endShape(CLOSE);
	// bottom
	beginShape();
	for (int i = 0; i < sides; i++) {
		float x = cos(radians(i * angle)) * r1;
		float y = sin(radians(i * angle)) * r1;
		vertex(x, y, halfHeight);
	}
	endShape(CLOSE);
	// draw body
	beginShape(TRIANGLE_STRIP);
	for (int i = 0; i < sides + 1; i++) {
		float x1 = cos(radians(i * angle)) * r2;
		float y1 = sin(radians(i * angle)) * r2;
		float x2 = cos(radians(i * angle)) * r1;
		float y2 = sin(radians(i * angle)) * r1;
		vertex(x1, y1, - halfHeight);
		vertex(x2, y2, halfHeight);
	}
	endShape(CLOSE);
	popMatrix();
}

void settings() {
	size(VIEW_SIZE_X, VIEW_SIZE_Y, P3D);
}

void setup() {
	g_font = createFont("Courier", 32);
	
	for (int i = 0; i < g_Data_num; i++) 
		for (int j = 0; j < g_Data_lng; j++) 
			g_Data[i][j] = 0;
	
	delay(100);
	
	g_lines = loadStrings(g_filename);
	
	g_output_file = createWriter("output.csv");
}
