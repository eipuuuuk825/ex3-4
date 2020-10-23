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
//String g_filename = "MyMotion.csv";
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
}

class Yubi
{
	Point m_p = new Point();
	float m_b;
	
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

/* b norm */
float[] g_b_max = {0, 0, 0, 0, 0};
float[] g_b_min = {20, 20, 20, 20, 20};

/* param */
final float g_R_YUBI = 10;
final float g_R_OBJ = 30;
final Point g_OBJ_POS = new Point(VIEW_SIZE_X / 2 - 50, VIEW_SIZE_Y / 2 + 50, - 150);

/* yubi */
Yubi g_yubi_oya = new Yubi();
Yubi g_yubi_hito = new Yubi();
Yubi g_yubi_naka = new Yubi();

void drawHand() {  
	noStroke();
	ambientLight(189, 189, 189);
	lightSpecular(255, 255, 255);
	directionalLight(102, 102, 102, 1, 1, 1);
	specular(255, 255, 255);
	shininess(5.0);
	
	pushMatrix();
	translate(VIEW_SIZE_X / 2 + 170, VIEW_SIZE_Y / 2 + 250, 0);
	rotateZ( - g_Euler[2]);
	rotateY( - g_Euler[0]);
	rotateX( - g_Euler[1]);
	
	buildHandShape();
	
	popMatrix();
}

void buildHandShape() {
	final float hand_size = 350;
	final float d = hand_size * 0.05;
	
	pushMatrix();
	rotateY(PI);
	rotateX(PI / 2); /* tmp */
	// rotateZ( - PI*0.4);
	
	drawOya(hand_size, d);
	drawHito(hand_size, d);
	drawNaka(hand_size, d);
	drawKusuri(hand_size, d);
	drawKo(hand_size, d);
	
	popMatrix();
	
	/* hito */
	// pushMatrix();
	// translate( - 20, 0, - 50 - 100 * g_yubi_hito.m_b);
	// sphere(g_R_YUBI);
	// g_yubi_hito.get_pos();
	// popMatrix();
}

void drawOya(float hand_size, float d) {
	final float h_hira = hand_size * 0.19;
	final float h_1 = h_hira * 0.9;
	final float h_2 = h_1 * 0.8;
	
	final float d_hira = d * 0.7;
	final float d_1 = d_hira * 0.8;
	final float d_2 = d_1 * 0.8;
	
	pushMatrix();
	fill(#ff0000);
	/* hira */
	rotateY(PI * 0.12);
	rotateX(- PI * 0.1);
	translate(hand_size * 0.08, 0, hand_size * 0.14);
	drawCylinder(d_hira, h_hira);
	/* 1 */
	translate(0, 0, h_hira);
	drawCylinder(d_1, h_1);
	/* 2 */
	translate(0, 0, h_1);
	drawCylinder(d_2, h_2);
	
	fill(#888888);
	popMatrix();
}

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
	drawCylinder(d_hira, h_hira);
	/* 1 */
	translate(0, 0, h_hira);
	rotateY( - PI * 0.04);
	drawCylinder(d_1, h_1);
	/* 2 */
	translate(0, 0, h_1);
	rotateY(PI * 0.005);
	drawCylinder(d_2, h_2);
	/* 3 */
	translate(0, 0, h_2);
	rotateY(PI * 0.005);
	drawCylinder(d_3, h_3);
	popMatrix();
}

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
	rotateX(PI * 0.015);
	rotateY(PI * 0.02);
	drawCylinder(d_hira, h_hira);
	/* 1 */
	translate(0, 0, h_hira);
	rotateX( - PI * 0.015 * 2);
	rotateY(- PI * 0.02);
	drawCylinder(d_1, h_1);
	/* 2 */
	translate(0, 0, h_1);
	rotateX(PI * 0.015);
	drawCylinder(d_2, h_2);
	/* 3 */
	translate(0, 0, h_2);
	drawCylinder(d_3, h_3);
	popMatrix();
}

void drawKusuri(float hand_size, float d) {
	final float h_hira = hand_size * 0.39;
	final float h_1 = h_hira * 0.55;
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
	drawCylinder(d_hira, h_hira);
	/* 1 */
	translate(0, 0, h_hira);
	rotateY(PI * 0.01);
	drawCylinder(d_1, h_1);
	/* 2 */
	translate(0, 0, h_1);
	drawCylinder(d_2, h_2);
	/* 3 */
	translate(0, 0, h_2);
	drawCylinder(d_3, h_3);
	popMatrix();
}

void drawKo(float hand_size, float d) {
	final float h_hira = hand_size * 0.38;
	final float h_1 = h_hira * 0.45;
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
	drawCylinder(d_hira, h_hira);
	/* 1 */
	translate(0, 0, h_hira);
	rotateY(PI * 0.037);
	drawCylinder(d_1, h_1);
	/* 2 */
	translate(0, 0, h_1);
	rotateY(PI * 0.01);
	drawCylinder(d_2, h_2);
	/* 3 */
	translate(0, 0, h_2);
	rotateY(PI * 0.01);
	drawCylinder(d_3, h_3);
	popMatrix();
}

void drawObstacle() {
	if (g_yubi_hito.get_dist(g_OBJ_POS) < g_R_YUBI + g_R_OBJ)
		fill(#ff0000);
	else
		fill(#888888);
	
	// pushMatrix();
	// translate(g_OBJ_POS.m_x, g_OBJ_POS.m_y, g_OBJ_POS.m_z);
	// sphere(g_R_OBJ);
	// popMatrix();
	
	//   pushMatrix();
	//   translate(g_OBJ_POS.m_x, g_OBJ_POS.m_y, g_OBJ_POS.m_z);
	//   rotateX(PI/2);
	//   drawCylinder(50, 300);
	//   popMatrix();
}

void check_axis()
{
	pushMatrix();
	fill(#888888);
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
	g_dt = float(co[0]) - g_t;
	g_t = float(co[0]);
	for (int i = 0; i < 3; i++) g_a[i] = float(co[i + 1]);
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
			g_yubi_oya.m_b = norm;
			break;
			case YUBI_HITO:
			g_yubi_hito.m_b = norm;
			break;
			case YUBI_NAKA:
			g_yubi_naka.m_b = norm;
			break;
		}
	}
	//println(b_norm[YUBI_OYA]+", "+b_norm[YUBI_HITO]+", "+b_norm[YUBI_NAKA]);
}

void draw() {
	background(#000000);
	fill(#ffffff);
	
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
		text("Disable home position by pressing \"n\"", 20, VIEW_SIZE_Y - 30);
	} else {
		quaternionToEuler(g_q, g_Euler);
		text("Point FreeIMU's X axis to your monitor then press \"h\"", 20, VIEW_SIZE_Y - 30);
	}
	
	for (int i = 0; i < 3; i++) g_ac[i] = g_a[i] * (9.8 / 272.5);
	g_aw = quatTranslate(g_ac); // 0;-z, 1:-x, 2:-y
	for (int i = 0; i < 3; i++) g_af[i] = - g_aw[i]; // (2*g_af[i] + (-1)*g_aw[i] - 0)/3;
	g_av[0] = - g_af[0];
	g_av[1] = - g_af[1] + 9.61;
	g_av[2] = - g_af[2];
	
	textFont(g_font, 20);
	textAlign(LEFT, TOP);
	text("Acc. : [" + nfs(g_av[0], 0, 2) + ", " + nfs(g_av[1], 0, 2) + ", " + nfs(g_av[2], 0, 2) + "]\n" +
		"Time : " + nfs(g_dt, 0, 2) + "[ms]", 20, 20);
	text("Euler angles : \n" + 
		"Yaw(psi)  : "   + nfs(degrees(g_Euler[0]), 0, 2) + "\n" + 
		"Pitch(theta) : " + nfs(degrees(g_Euler[1]), 0, 2) + "\n" + 
		"Roll(phi)  : "  + nfs(degrees(g_Euler[2]), 0, 2), 350, 20);
	text("Flexions : \n" + nfs(g_b[0], 0, 2) + "\n" + nfs(g_b[1], 0, 2) + "\n" + nfs(g_b[2], 0, 2) + "\n" + nfs(g_b[3], 0, 2) + "\n" + nfs(g_b[4], 0, 2), 600, 20);
	
	drawHand();
	drawObstacle();
	
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
void drawCylinder(float r2, float h) {
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
}
