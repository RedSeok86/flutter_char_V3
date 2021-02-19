# flutter_chat_V3

디자인 리뉴얼 버전


## Ref. Provider
현재 선택되어있는 프로필의 ID 호출은 
### Function case
```
Provider.of<nowProfile>(context, listen: false).getMyProfile().myPid;
```

### Widget Case
```
Consumer<nowProfile>(
     builder: (context, profile, _) {
        return Text(profile.getMyProfile.myPid);
     }
```
     
