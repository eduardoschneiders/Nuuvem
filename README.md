How to run the project:
```
docker-compose up
```

And then acess the url:
```
localhost:3000
```

How to simulate browser request:
```
curl -X POST -F 'file=@example_input.tab' localhost:3000/send_data
```