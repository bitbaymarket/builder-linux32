
#include <QApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QFontDatabase>

#include "mainwindow.h"

int main(int argc, char *argv[])
{
	Q_INIT_RESOURCE(fonts);
	Q_INIT_RESOURCE(qtapp);

	QApplication app(argc, argv);
	QCoreApplication::setOrganizationName("QtProject");
	QCoreApplication::setApplicationName("Application Example");
	QCoreApplication::setApplicationVersion(QT_VERSION_STR);
	QCommandLineParser parser;
	parser.setApplicationDescription(QCoreApplication::applicationName());
	parser.addHelpOption();
	parser.addVersionOption();
	parser.addPositionalArgument("file", "The file to open.");
	parser.process(app);

    app.setAttribute(Qt::AA_UseHighDpiPixmaps);

    QFontDatabase::addApplicationFont(":/fonts/fonts/Roboto-Black.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/Roboto-BlackItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/Roboto-Bold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/Roboto-BoldItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/Roboto-Italic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/Roboto-Light.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/Roboto-LightItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/Roboto-Medium.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/Roboto-MediumItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/Roboto-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/Roboto-Thin.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/Roboto-ThinItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/RobotoCondensed-Bold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/RobotoCondensed-BoldItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/RobotoCondensed-Italic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/RobotoCondensed-Light.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/RobotoCondensed-LightItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/RobotoCondensed-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/RobotoMono-BoldItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/RobotoMono-Bold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/RobotoMono-Italic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/fonts/RobotoMono-Regular.ttf");

#ifdef Q_OS_MAC
    QFont font("Roboto", 15);
#else
    QFont font("Roboto", 11);
#endif
    QApplication::setFont(font);

	MainWindow mainWin;
	if (!parser.positionalArguments().isEmpty())
		mainWin.loadFile(parser.positionalArguments().first());
	mainWin.show();
	return app.exec();
}
