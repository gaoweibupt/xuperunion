package utils

import (
	"io/ioutil"
	"log"
	"os"
)

/**
 * 生成文件
 */
func writeFileUsingFilename(filename string, content []byte) error {
	//函数向filename指定的文件中写入数据(字节数组)。如果文件不存在将按给出的权限创建文件，否则在写入数据之前清空文件。
	err := ioutil.WriteFile(filename, content, 0666)
	return err
}

/*
 *	生成文件 调用内部方法 外部提供给其它包使用
 */
func WriteToFile(filename string, content []byte) error {
	return writeFileUsingFilename(filename, content)
}

/**
 * 读取文件
 */
func readFileUsingFilename(filename string) ([]byte, error) {
	//从filename指定的文件中读取数据并返回文件的内容。
	//成功的调用返回的err为nil而非EOF。
	//因为本函数定义为读取整个文件，它不会将读取返回的EOF视为应报告的错误。
	content, err := ioutil.ReadFile(filename)
	if os.IsNotExist(err) {
		log.Printf("File [%v] does not exist", filename)
	}
	return content, err
}
