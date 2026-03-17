package util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * application.properties 파일에서 설정값을 읽는 유틸리티 클래스
 */
public class ConfigLoader {
    private static Properties properties;
    
    static {
        properties = new Properties();
        try {
            // application.properties 파일을 읽음
            InputStream input = ConfigLoader.class.getClassLoader()
                    .getResourceAsStream("application.properties");
            if (input != null) {
                properties.load(input);
                input.close();
            }
        } catch (IOException e) {
            System.err.println("application.properties 파일을 찾을 수 없습니다: " + e.getMessage());
        }
    }
    
    /**
     * 설정값 조회
     * @param key 설정 키
     * @return 설정값 (없으면 null 반환)
     */
    public static String getProperty(String key) {
        return properties.getProperty(key);
    }
    
    /**
     * 설정값 조회 (기본값 지정 가능)
     * @param key 설정 키
     * @param defaultValue 기본값
     * @return 설정값 (없으면 기본값 반환)
     */
    public static String getProperty(String key, String defaultValue) {
        return properties.getProperty(key, defaultValue);
    }
}
