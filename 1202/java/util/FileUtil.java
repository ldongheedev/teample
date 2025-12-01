package util;

import java.io.File;
import java.io.IOException;
import jakarta.servlet.http.Part;

public class FileUtil {
    // 파일명 추출 유틸리티
    public static String getFileName(Part part) {
        if (part == null) return null;
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return null;
    }

    // 파일 저장 및 경로 반환
    public static String uploadFile(Part part, String uploadDir, String savePath) throws IOException {
        if (part == null || part.getSize() == 0) return null;
        
        String fileName = getFileName(part);
        if (fileName != null && !fileName.isEmpty()) {
            // 폴더 없으면 생성
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();
            
            // 파일 저장 (중복 방지를 위해 UUID 등을 붙이면 더 좋지만, 기존 로직 유지)
            part.write(uploadDir + File.separator + fileName);
            return savePath + "/" + fileName;
        }
        return null;
    }
}